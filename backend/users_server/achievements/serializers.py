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
