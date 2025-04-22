from django.db.models.signals import post_save
from django.dispatch import receiver
from users.models import ClientProfile
from .models import (
    TransactionCategory,
    Achievement
)


@receiver(post_save, sender=TransactionCategory)
def create_achievements_for_new_category(
        sender,
        instance,
        created,
        **kwargs
):
    if created:
        all_profile_ids = ClientProfile.objects.values_list('id', flat=True)
        existing_achievement_profile_ids = Achievement.objects.filter(
            category=instance
        ).values_list('user_id', flat=True)
        profile_ids_to_create_for = list(set(all_profile_ids) - set(existing_achievement_profile_ids))

        if profile_ids_to_create_for:
            profiles_to_create_for = ClientProfile.objects.filter(id__in=profile_ids_to_create_for)
            achievements_to_create = []

            for profile in profiles_to_create_for:
                achievements_to_create.append(
                    Achievement(
                        user=profile,
                        category=instance,
                        value=0
                    )
                )

            Achievement.objects.bulk_create(achievements_to_create)

