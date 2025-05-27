from django.contrib import admin

from users.models import (
    Users,
    ClientProfile
)

admin.site.register(Users)
admin.site.register(ClientProfile)
