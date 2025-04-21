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
from django.utils import timezone


class TransactionQuerySet(models.QuerySet):
    def aggregate_by_hour(self, start_date):
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
        day_start = start_date.replace(hour=0, minute=0, second=0, microsecond=0)
        hourly_data = {}

        for h in range(24):
            hour_dt = day_start + datetime.timedelta(hours=h)
            key = hour_dt.isoformat(timespec='seconds').replace('+00:00', 'Z')
            hourly_data[key] = 0

        next_day_start = day_start + datetime.timedelta(days=1)
        key_24 = next_day_start.isoformat(timespec='seconds').replace('+00:00', 'Z')
        hourly_data[key_24] = 0

        for entry in aggregated:
            int_hour = entry['bucket_hour']
            total_amount = entry['total_amount']

            if 0 <= int_hour < 24:
                bucket_dt = day_start + datetime.timedelta(hours=int_hour)
                key = bucket_dt.isoformat(timespec='seconds').replace('+00:00', 'Z')
            elif int_hour == 24:
                key = next_day_start.isoformat(timespec='seconds').replace('+00:00', 'Z')
            else:
                continue

            hourly_data[key] = total_amount

        return hourly_data

    def aggregate_by_day(self, start_date, end_date):
        daily_aggregation = self.annotate(
            day=TruncDate('creation_date')
        ).values('day').annotate(
            total_amount=Sum('amount')
        ).order_by('day')
        daily_data = {}
        current_date = start_date
        end_date_only = end_date

        while current_date <= end_date_only:
            daily_data[current_date.isoformat()] = 0
            current_date += datetime.timedelta(days=1)

        for entry in daily_aggregation:
            date_obj = entry['day']
            total_amount = entry['total_amount']

            if isinstance(date_obj, datetime.date):
                day_start_aware = timezone.make_aware(
                    datetime.datetime.combine(date_obj, datetime.time.min),
                    timezone.get_current_timezone()
                )
                day_start_utc = day_start_aware.astimezone(timezone.utc)
            elif isinstance(date_obj, datetime.datetime) and timezone.is_naive(date_obj):
                day_start_aware = timezone.make_aware(date_obj, timezone.get_current_timezone())
                day_start_utc = day_start_aware.astimezone(timezone.utc)
            else:
                continue

            key = day_start_utc.isoformat(timespec='seconds').replace('+00:00', 'Z')
            daily_data[key] = total_amount

        return daily_data
