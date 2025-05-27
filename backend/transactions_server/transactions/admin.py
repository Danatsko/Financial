from django.contrib import admin

from transactions.models import (
    TransactionType,
    TransactionCategory,
    Transaction
)

admin.site.register(TransactionType)
admin.site.register(TransactionCategory)
admin.site.register(Transaction)
