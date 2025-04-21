from django.db.models.signals import post_save
from django.dispatch import receiver
from .models import ClientProfile
from achievements.models import (
    TransactionCategory,
    Achievement
)


@receiver(post_save, sender=ClientProfile)
def create_user_achievements(
        sender,
        instance,
        created,
        **kwargs
):
    if created:
        categories = TransactionCategory.objects.all()
        achievements_to_create = []

        for category in categories:
            achievement = Achievement(
                user=instance,
                category=category,
                value=0
            )

            achievements_to_create.append(achievement)

        if achievements_to_create:
            Achievement.objects.bulk_create(achievements_to_create)
