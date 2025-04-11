from django.db import models

from transactions.querysets import TransactionQuerySet


class TransactionManager(models.Manager):
    def get_queryset(self):
        return TransactionQuerySet(self.model, using=self._db)

    def aggregate_by_hour(self):
        return self.get_queryset().aggregate_by_hour()

    def aggregate_by_day(self, start_date, end_date):
        return self.get_queryset().aggregate_by_day(start_date, end_date)
