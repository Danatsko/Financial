import datetime
from collections import defaultdict

from django.db.models import (
    Sum,
    FloatField,
    Count
)
from django.db.models.functions import Coalesce
from django.utils import timezone
from oauth2_provider.contrib.rest_framework import TokenMatchesOASRequirements
from rest_framework import mixins
from rest_framework.decorators import action
from rest_framework.exceptions import (
    ValidationError,
    NotFound
)
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from transactions.models import (
    Transaction,
    TransactionType,
    TransactionCategory
)
from transactions.serializers import (
    TransactionWriteSerializer,
    DateRangeSerializer,
    TransactionReadSerializer,
    MonthlyBudgetSerializer
)


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
                type_categories_data = {}

                for category in type_categories:
                    transactions_list = categories_transactions.get(category, [])
                    category_sum = sum(transaction['amount'] for transaction in transactions_list)
                    percentage = round((category_sum / type_total * 100), 1) if type_total > 0 else 0
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

    @action(
        methods=['GET'],
        detail=True,
        serializer_class=TransactionReadSerializer
    )
    def get_monthly_recommendations(self, request, pk):
        serializer_monthly_budget = MonthlyBudgetSerializer(data=request.query_params)

        if serializer_monthly_budget.is_valid():
            user_id = pk
            monthly_budget = serializer_monthly_budget.validated_data['monthly_budget']
            today = timezone.now().date()
            first_day_of_current_month = today.replace(day=1)
            last_day_of_last_month = first_day_of_current_month - datetime.timedelta(days=1)
            first_day_of_last_month = last_day_of_last_month.replace(day=1)
            start_date = first_day_of_last_month
            end_date = last_day_of_last_month
            current_month = start_date.strftime("%Y-%m")
            transaction_types = TransactionType.objects.all()
            transactions_last_month = Transaction.objects.filter(
                user_id=user_id,
                creation_date__date__range=(start_date, end_date)
            ).select_related('category', 'type')
            recommendations_list = []
            type_name_for_budget = 'costs'
            total_spending_for_budget = 0

            for transaction_type in transaction_types:
                type_name = transaction_type.name
                transactions_for_this_type = transactions_last_month.filter(type=transaction_type)
                total_for_this_type = transactions_for_this_type.aggregate(
                    total=Coalesce(
                        Sum('amount'),
                        0,
                        output_field=FloatField()
                    )
                )['total']

                if type_name == type_name_for_budget:
                    total_spending_for_budget = total_for_this_type

                all_categories_for_this_type = transaction_type.categories.all()
                categories_with_activity_ids = transactions_for_this_type.values_list('category_id', flat=True).distinct()
                categories_with_no_activity_qs = all_categories_for_this_type.exclude(id__in=categories_with_activity_ids)

                if categories_with_no_activity_qs.exists():
                    no_activity_category_names = list(categories_with_no_activity_qs.values_list('name', flat=True))

                    recommendations_list.append({
                        "status": "no_activity_in_category_last_month",
                        "data": {
                            "types": type_name,
                            "categories": no_activity_category_names,
                            "month": current_month
                        }
                    })

                if total_for_this_type == 0:
                    recommendations_list.append({
                        "status": "no_transactions_for_type",
                        "data": {
                            "types": type_name,
                            "month": current_month
                        }
                    })
                else:
                    category_sums_for_this_type_qs = transactions_for_this_type.values(
                        'category__id',
                        'category__name'
                    ).annotate(
                        sum=Coalesce(
                            Sum('amount'),
                            0,
                            output_field=FloatField())
                    )
                    category_counts_for_this_type_qs = transactions_for_this_type.values(
                        'category__id',
                        'category__name'
                    ).annotate(
                        count=Count('id')
                    )
                    category_sum_data_for_this_type = list(category_sums_for_this_type_qs)
                    category_count_data_for_this_type = list(category_counts_for_this_type_qs)
                    min_sum_for_type = None
                    max_sum_for_type = None
                    min_count_for_type = None
                    max_count_for_type = None
                    min_sum_categories_data_for_type = []
                    max_sum_categories_data_for_type = []
                    min_count_categories_data_for_type = []
                    max_count_categories_data_for_type = []

                    if category_sum_data_for_this_type:
                        min_sum_for_type = min(item['sum'] for item in category_sum_data_for_this_type)
                        max_sum_for_type = max(item['sum'] for item in category_sum_data_for_this_type)

                        for item in category_sum_data_for_this_type:
                            if item['sum'] == min_sum_for_type:
                                min_sum_categories_data_for_type.append(item['category__name'])
                            if item['sum'] == max_sum_for_type:
                                max_sum_categories_data_for_type.append(item['category__name'])

                    if min_sum_categories_data_for_type:
                        recommendations_list.append({
                            "status": "lowest_sum_category_for_type",
                            "data": {
                                "types": type_name,
                                "categories": min_sum_categories_data_for_type,
                                "sum": min_sum_for_type,
                                "month": current_month
                            }
                        })

                    if max_sum_categories_data_for_type:
                        recommendations_list.append({
                            "status": "highest_sum_category_for_type",
                            "data": {
                                "types": type_name,
                                "categories": max_sum_categories_data_for_type,
                                "sum": max_sum_for_type,
                                "month": current_month
                            }
                        })

                    if category_count_data_for_this_type:
                        min_count_for_type = min(item['count'] for item in category_count_data_for_this_type)
                        max_count_for_type = max(item['count'] for item in category_count_data_for_this_type)

                        for item in category_count_data_for_this_type:
                            if item['count'] == min_count_for_type:
                                min_count_categories_data_for_type.append(item['category__name'])
                            if item['count'] == max_count_for_type:
                                max_count_categories_data_for_type.append(item['category__name'])

                    if min_count_categories_data_for_type:
                        recommendations_list.append({
                            "status": "lowest_count_category_for_type",
                            "data": {
                                "types": type_name,
                                "categories": min_count_categories_data_for_type,
                                "count": min_count_for_type,
                                "month": current_month
                            }
                        })

                    if max_count_categories_data_for_type:
                        recommendations_list.append({
                            "status": "highest_count_category_for_type",
                            "data": {
                                "types": type_name,
                                "categories": max_count_categories_data_for_type,
                                "count": max_count_for_type,
                                "month": current_month
                            }
                        })

            if total_spending_for_budget > monthly_budget:
                recommendations_list.append({
                    "status": "budget_exceeded_last_month",
                    "data": {
                        "budget_amount": monthly_budget,
                        "total_spent": total_spending_for_budget,
                        "excess_amount": total_spending_for_budget - monthly_budget,
                        "month": current_month
                    }
                })
            else:
                recommendations_list.append({
                    "status": "budget_within_limit_last_month",
                    "data": {
                        "budget_amount": monthly_budget,
                        "total_spent": total_spending_for_budget,
                        "remaining_amount": monthly_budget - total_spending_for_budget,
                        "month": current_month
                    }
                })

            response_data = {"recommendations": recommendations_list}

            return Response(response_data)
        else:
            raise ValidationError(serializer_monthly_budget.errors)

    @action(methods=['DELETE'], detail=True)
    def delete_all_user_transactions(self, request, pk):
        transactions = Transaction.objects.filter(user_id=pk)

        if not transactions.exists():
            raise NotFound({'detail': f'No transactions found for user ID {pk}.'})

        transactions.delete()

        return Response(status=204)
