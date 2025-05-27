from django.db import models

from users.models import ClientProfile


class TransactionType(models.Model):
    name = models.CharField(max_length=250, unique=True)

    def __str__(self):
        return self.name


class TransactionCategory(models.Model):
    name = models.CharField(max_length=250, unique=True)
    type = models.ForeignKey(TransactionType, on_delete=models.CASCADE, related_name='categories')

    def __str__(self):
        return self.name


class Achievement(models.Model):
    user = models.ForeignKey(ClientProfile, on_delete=models.CASCADE, related_name='achievements')
    category = models.ForeignKey(TransactionCategory, on_delete=models.CASCADE, related_name='achievements')
    value = models.IntegerField()

    class Meta:
        unique_together = (('user', 'category'),)

    def __str__(self):
        return f"{self.category.name} achievement for {self.user.user.email}."
