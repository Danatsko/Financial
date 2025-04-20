from collections import defaultdict

from django.db.models import Sum
from oauth2_provider.contrib.rest_framework import TokenMatchesOASRequirements
from rest_framework import mixins
from rest_framework.decorators import action
from rest_framework.exceptions import ValidationError, NotFound
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from transactions.models import Transaction, TransactionType, TransactionCategory
from transactions.serializers import TransactionWriteSerializer, DateRangeSerializer, TransactionReadSerializer


class TransactionViewSet(
    mixins.CreateModelMixin,
    mixins.UpdateModelMixin,
    mixins.DestroyModelMixin,
    GenericViewSet
):
    queryset = Transaction.objects.all()
    serializer_class = TransactionWriteSerializer
    permission_classes = [TokenMatchesOASRequirements]
    required_alternate_scopes = {
        'GET': [["svc:transactions:own:list:read"], ["svc:transactions:own:analytics:read"]],
        'POST': [["svc:transactions:own:item:create"],],
        'PUT': [["svc:transactions:own:item:update"],],
        'PATCH': [["svc:transactions:own:item:update"],],
        'DELETE': [["svc:transactions:own:all:delete"], ["svc:transactions:own:item:delete"]]
    }

    @action(
        methods=['GET'],
        detail=True,
        serializer_class=TransactionReadSerializer
    )
    def get_transactions_data(self, request, pk):
        serializer_date_range = DateRangeSerializer(data=request.query_params)

        if serializer_date_range.is_valid():
            start_date = serializer_date_range.validated_data['start_date']
            end_date = serializer_date_range.validated_data['end_date']
            transactions = Transaction.objects.filter(
                user_id=pk,
                creation_date__range=(start_date, end_date)
            ).order_by('-creation_date')

            if not transactions.exists():
                return Response({
                    'transactions': [],
                    'detail': f'No transactions found for user ID {pk} in date range {start_date} - {end_date}.'
                })

            serialized_transactions = TransactionReadSerializer(transactions, many=True).data

            return Response({'transactions': serialized_transactions})
        else:
            raise ValidationError(serializer_date_range.errors)

    @action(
        methods=['GET'],
        detail=True,
        serializer_class=TransactionReadSerializer
    )
    def get_analyse_data(self, request, pk):
        serializer_date_range = DateRangeSerializer(data=request.query_params)

        if serializer_date_range.is_valid():
            start_date = serializer_date_range.validated_data['start_date']
            end_date = serializer_date_range.validated_data['end_date']
            transactions = Transaction.objects.filter(
                user_id=pk,
                creation_date__range=(start_date, end_date)
            ).order_by('-creation_date').select_related('category', 'type')
            transaction_types = TransactionType.objects.all()
            serialized_transactions_list = TransactionReadSerializer(transactions, many=True).data
            categories_transactions = defaultdict(list)
            types_data = {}
            types_time_data = {}
            interval = end_date - start_date

            for serialized_transaction_dict in serialized_transactions_list:
                categories_transactions[serialized_transaction_dict['category']].append(serialized_transaction_dict)

            for type in transaction_types:
                type_categories = TransactionCategory.objects.filter(type=type).values_list('name', flat=True)
                type_qs = transactions.filter(type=type)
                type_total = type_qs.aggregate(total=Sum('amount'))['total'] or 0
                category_sums = {
                    item['category__name']: item['sum']
                    for item in type_qs.values('category__name').annotate(sum=Sum('amount'))
                }
                type_categories_data = {}

                for category in type_categories:
                    category_sum = category_sums.get(category, 0) or 0
                    percentage = round((category_sum / type_total * 100), 1) if type_total > 0 else 0
                    transactions_list = categories_transactions.get(category, [])
                    type_categories_data[category] = {
                        'percentage': percentage,
                        'transactions': transactions_list,
                    }

                if interval.days == 0:
                    type_time_data = type_qs.aggregate_by_hour(start_date)
                else:
                    type_time_data = type_qs.aggregate_by_day(start_date, end_date)

                types_time_data[type.name] = type_time_data
                types_data[type.name] = {
                    'total_amount': type_total,
                    'categories': type_categories_data
                }

            response_data = {
                'time_data': types_time_data,
                'type_data': types_data
            }

            if not transactions.exists():
                response_data[
                    'detail'] = f'No transactions found for user ID {pk} in date range {start_date} - {end_date}.'

            return Response(response_data)
        else:
            raise ValidationError(serializer_date_range.errors)

    @action(methods=['DELETE'], detail=True)
    def delete_all_user_transactions(self, request, pk):
        transactions = Transaction.objects.filter(user_id=pk)

        if not transactions.exists():
            raise NotFound({'detail': f'No transactions found for user ID {pk}.'})

        transactions.delete()

        return Response(status=204)
