from allauth.account.adapter import get_adapter
from django.contrib.auth import get_user_model
from django.http import JsonResponse
from oauth2_provider.contrib.rest_framework import TokenMatchesOASRequirements
from rest_framework import (
    status,
    mixins
)
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.decorators import action
from rest_framework.views import APIView
from rest_framework.viewsets import GenericViewSet

from server.authentication import GatewayAndClientTokenAuthentication
from server.permissions import GatewayTokenMatchesOASRequirements
from .serializers import (
    UserClientProfileWriteSerializer,
    UserClientProfileReadSerializer
)

User = get_user_model()


class UserClientProfileViewSet(
    mixins.CreateModelMixin,
    GenericViewSet
):
    queryset = User.objects.all()
    serializer_class = UserClientProfileWriteSerializer
    permission_classes = [GatewayTokenMatchesOASRequirements]
    required_alternate_scopes = {
        'GET': [["users:own:profile:read"],],
        'POST': [["users:own:profile:create"],],
        'PUT': [["users:own:profile:update"],],
        'PATCH': [["users:own:profile:update"],],
        'DELETE': [["users:own:profile:delete"],],
    }
    required_gateway_alternate_scopes = {
        'GET': [["svc:users:own:profile:read"],],
        'POST': [["svc:users:own:profile:create"],],
        'PUT': [["svc:users:own:profile:update"],],
        'PATCH': [["svc:users:own:profile:update"],],
        'DELETE': [["svc:users:own:profile:delete"],],
    }

    @action(
        detail=False,
        methods=['GET', 'PUT', 'PATCH', 'DELETE'],
        url_path='me',
        authentication_classes=[GatewayAndClientTokenAuthentication],
        serializer_class=UserClientProfileWriteSerializer,
        permission_classes=[
            TokenMatchesOASRequirements,
            GatewayTokenMatchesOASRequirements
        ]
    )
    def me(self, request):
        if request.method == 'GET':
            serializer = UserClientProfileReadSerializer(request.user)
            response_data = {'user': serializer.data}

            return Response(response_data)
        elif request.method in ['PUT', 'PATCH']:
            serializer = self.get_serializer(request.user, data=request.data, partial=True)

            serializer.is_valid(raise_exception=True)
            serializer.save()

            detail_serializer = UserClientProfileReadSerializer(request.user)

            response_data = {'user': detail_serializer.data}

            return Response(response_data)
        elif request.method == 'DELETE':
            request.user.delete()

            return Response(status=status.HTTP_204_NO_CONTENT)


class SocialLoginUrlAPIView(APIView):
    permission_classes = [AllowAny]

    def get(
            self,
            request,
            provider,
            *args,
            **kwargs
    ):
        django_http_request = request._request
        adapter = get_adapter(django_http_request)
        provider = adapter.get_provider(django_http_request, provider)
        login_url_path = provider.get_login_url(django_http_request)
        absolute_login_url = request.build_absolute_uri(login_url_path)

        return JsonResponse({'login_url': absolute_login_url})
