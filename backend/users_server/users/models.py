from django.contrib.auth.models import AbstractUser
from django.db import models


class Users(AbstractUser):
    username = models.CharField(max_length=150, unique=False, blank=True)
    email = models.EmailField(unique=True)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = ['username']

    def __str__(self):
        return self.email


class ClientProfile(models.Model):
    user = models.OneToOneField(Users, on_delete=models.CASCADE, related_name='client_profile')
    balance = models.FloatField()
    monthly_budget = models.FloatField()

    def __str__(self):
        return f"ClientProfile for {self.user.email}."
