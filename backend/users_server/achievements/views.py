from collections import defaultdict

from oauth2_provider.contrib.rest_framework import TokenMatchesOASRequirements
from rest_framework import mixins
from rest_framework.decorators import action
from rest_framework.exceptions import NotFound
from rest_framework.response import Response
from rest_framework.viewsets import GenericViewSet

from server.authentication import GatewayAndClientTokenAuthentication
from server.permissions import GatewayTokenMatchesOASRequirements
from .models import Achievement
from .serializers import (
    AchievementWriteSerializer,
    AchievementReadSerializer
)


class AchievementViewSet(
    mixins.ListModelMixin,
    GenericViewSet
):
    serializer_class = AchievementReadSerializer
    authentication_classes = [GatewayAndClientTokenAuthentication]
    permission_classes = [
        TokenMatchesOASRequirements,
        GatewayTokenMatchesOASRequirements
    ]
    required_alternate_scopes = {
        'GET': [["achievements:own:list:read"], ],
        'PUT': [["achievements:own:item:update"], ],
        'PATCH': [["achievements:own:item:update"], ],
    }
    required_gateway_alternate_scopes = {
        'GET': [["svc:achievements:own:list:read"], ],
        'PUT': [["svc:achievements:own:item:update"], ],
        'PATCH': [["svc:achievements:own:item:update"], ],
    }

    def get_queryset(self):
        return Achievement.objects.filter(user__user=self.request.user)

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        achievements_data = defaultdict(dict)

        for achievement in queryset:
            achievement_type = achievement.category.type.name
            achievements_data[achievement_type][achievement.category.name] = achievement.value

        return Response({'achievements': achievements_data})

    @action(
        detail=False,
        methods=['PATCH'],
        serializer_class=AchievementWriteSerializer
    )
    def increment_achievement_value(self, request):
        serializer = self.get_serializer(data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        category = serializer.validated_data.get("category")

        try:
            achievement = self.get_queryset().get(category=category)
        except Achievement.DoesNotExist:
            raise NotFound({"detail": "Achievement not found."})

        achievement.value += 1
        achievement.save()

        return Response({'achievement': AchievementReadSerializer(achievement).data})
