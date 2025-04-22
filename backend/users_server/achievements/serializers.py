from rest_framework import serializers

from .models import Achievement, TransactionCategory


class AchievementWriteSerializer(serializers.ModelSerializer):
    category = serializers.SlugRelatedField(
        queryset=TransactionCategory.objects.all(),
        slug_field='name'
    )

    class Meta:
        model = Achievement
        fields = ('category',)


class AchievementReadSerializer(serializers.ModelSerializer):
    user_id = serializers.PrimaryKeyRelatedField(source='user.user', read_only=True)
    category = serializers.SlugRelatedField(
        queryset=TransactionCategory.objects.all(),
        slug_field='name'
    )

    class Meta:
        model = Achievement
        fields = (
            'id',
            'user_id',
            'category',
            'value'
        )
        read_only_fields = ('__all__',)
