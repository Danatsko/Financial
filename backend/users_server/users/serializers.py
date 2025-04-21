from django.contrib.auth import get_user_model
from rest_framework import serializers
from .models import ClientProfile

User = get_user_model()


class UserClientProfileWriteSerializer(serializers.ModelSerializer):
    balance = serializers.FloatField(required=True)
    monthly_budget = serializers.FloatField(required=True)

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'email',
            'password',
            'balance',
            'monthly_budget'
        )
        extra_kwargs = {
            'id': {'read_only': True},
            'password': {'write_only': True},
        }

    def create(self, validated_data):
        balance = validated_data.pop('balance', None)
        monthly_budget = validated_data.pop('monthly_budget', None)
        user = User.objects.create_user(**validated_data)

        ClientProfile.objects.create(
            user=user,
            balance=balance,
            monthly_budget=monthly_budget
        )

        return user

    def update(self, instance, validated_data):
        password = validated_data.pop('password', None)
        balance = validated_data.pop('balance', None)
        monthly_budget = validated_data.pop('monthly_budget', None)
        instance = super().update(instance, validated_data)

        if password is not None:
            instance.set_password(password)
            instance.save()

        profile = instance.client_profile

        if balance is not None:
            profile.balance = balance
        if monthly_budget is not None:
            profile.monthly_budget = monthly_budget

        profile.save()

        return instance


class UserClientProfileReadSerializer(serializers.ModelSerializer):
    balance = serializers.FloatField(source='client_profile.balance')
    monthly_budget = serializers.FloatField(source='client_profile.monthly_budget')
    date_joined = serializers.DateTimeField(format='%Y-%m-%dT%H:%M:%SZ')

    class Meta:
        model = User
        fields = (
            'id',
            'username',
            'email',
            'balance',
            'monthly_budget',
            'date_joined'
        )
        read_only_fields = ('__all__',)
