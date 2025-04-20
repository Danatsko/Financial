from rest_framework import serializers

from transactions.models import (
    TransactionType,
    TransactionCategory,
    Transaction
)


class TransactionWriteSerializer(serializers.ModelSerializer):
    type = serializers.SlugRelatedField(
        queryset=TransactionType.objects.all(),
        slug_field='name'
    )
    category = serializers.SlugRelatedField(
        queryset=TransactionCategory.objects.all(),
        slug_field='name'
    )

    class Meta:
        model = Transaction
        fields = (
            'id',
            'user_id',
            'type',
            'amount',
            'title',
            'payment_method',
            'description',
            'category',
            'creation_date'
        )
        read_only_fields = ('id',)

    def validate(self, data):
        request = self.context.get('request')

        if not request or request.method not in ['POST', 'PUT', 'PATCH']:
            return data

        is_update = self.instance is not None
        type_name_to_validate = data.get('type', self.instance.type.name if is_update else None)
        category_name_to_validate = data.get('category', self.instance.category.name if is_update else None)

        if type_name_to_validate is not None and category_name_to_validate is not None:
            try:
                category_instance = TransactionCategory.objects.get(name=category_name_to_validate)
                type_instance = TransactionType.objects.get(name=type_name_to_validate)

                if type_instance.name != category_instance.type.name:
                    raise serializers.ValidationError("The category does not match the type.")
            except TransactionCategory.DoesNotExist:
                raise serializers.ValidationError("Invalid category name provided.")
            except TransactionType.DoesNotExist:
                raise serializers.ValidationError("Invalid type name provided.")

        return data


class TransactionReadSerializer(serializers.ModelSerializer):
    type = serializers.SlugRelatedField(
        queryset=TransactionType.objects.all(),
        slug_field='name'
    )
    category = serializers.SlugRelatedField(
        queryset=TransactionCategory.objects.all(),
        slug_field='name'
    )

    class Meta:
        model = Transaction
        fields = (
            'id',
            'user_id',
            'type',
            'amount',
            'title',
            'payment_method',
            'description',
            'category',
            'creation_date'
        )
        read_only_fields = ('__all__',)
