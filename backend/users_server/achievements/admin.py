from django.contrib import admin

from achievements.models import (
    TransactionType,
    TransactionCategory,
    Achievement
)

admin.site.register(TransactionType)
admin.site.register(TransactionCategory)
admin.site.register(Achievement)
