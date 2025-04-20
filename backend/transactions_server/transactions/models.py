from django.db import models

from transactions.managers import TransactionManager


class TransactionType(models.Model):
    name = models.CharField(max_length=250, unique=True)

    def __str__(self):
        return self.name


class TransactionCategory(models.Model):
    name = models.CharField(max_length=250, unique=True)
    type = models.ForeignKey(TransactionType, on_delete=models.CASCADE, related_name='categories')

    def __str__(self):
        return self.name


class Transaction(models.Model):
    user_id = models.IntegerField()
    type = models.ForeignKey(TransactionType, on_delete=models.CASCADE, related_name='transactions')
    amount = models.FloatField()
    title = models.CharField(max_length=250)
    payment_method = models.CharField(max_length=250, blank=True)
    description = models.CharField(max_length=250, blank=True)
    category = models.ForeignKey(TransactionCategory, on_delete=models.CASCADE, related_name='transactions')
    creation_date = models.DateTimeField()

    objects = TransactionManager()

    def __str__(self):
        return f"Transaction \"{self.title[:10]}...\" from {self.user_id} for {self.creation_date}"
