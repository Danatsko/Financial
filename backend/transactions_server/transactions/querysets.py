import datetime

from django.db import models
from django.db.models import (
    Sum,
    F,
    Value,
    Case,
    When,
    IntegerField,
    Q
)
from django.db.models.functions import (
    ExtractHour,
    ExtractMinute,
    ExtractSecond,
    TruncDate
)


class TransactionQuerySet(models.QuerySet):
    def aggregate_by_hour(self):
        annotated_qs = self.annotate(
            hour=ExtractHour('creation_date'),
            minute=ExtractMinute('creation_date'),
            second=ExtractSecond('creation_date')
        ).annotate(
            bucket_hour=Case(
                When(Q(minute__gt=0) | Q(second__gt=0),
                     then=Case(
                         When(hour__lt=23, then=F('hour') + Value(1)),
                         default=Value(24),
                         output_field=IntegerField()
                     )),
                default=F('hour'),
                output_field=IntegerField()
            )
        )
        aggregated = annotated_qs.values('bucket_hour').annotate(
            total_amount=Sum('amount')
        ).order_by('bucket_hour')
        hourly_data = {hour: 0 for hour in range(25)}

        for entry in aggregated:
            hourly_data[entry['bucket_hour']] = entry['total_amount']

        return hourly_data

    def aggregate_by_day(self, start_date, end_date):
        daily_aggregation = self.annotate(
            day=TruncDate('creation_date')
        ).values('day').annotate(
            total_amount=Sum('amount')
        ).order_by('day')
        daily_data = {}
        current_date = start_date.date()
        end_date_only = end_date.date()

        while current_date <= end_date_only:
            daily_data[current_date.isoformat()] = 0
            current_date += datetime.timedelta(days=1)

        for entry in daily_aggregation:
            daily_data[entry['day'].isoformat()] = entry['total_amount']

        return daily_data
