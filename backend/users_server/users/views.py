import uuid

from allauth.account.adapter import get_adapter
from django.contrib.auth import get_user_model
from django.conf import settings
from django.utils.timezone import (
    now,
    timedelta
)
from django.http import JsonResponse
from django.core.cache import cache
from django.shortcuts import redirect
from oauth2_provider.contrib.rest_framework import TokenMatchesOASRequirements
from oauth2_provider.models import (
    get_application_model,
    AccessToken,
    RefreshToken
)
from oauth2_provider.settings import oauth2_settings
from oauthlib.common import generate_token
from rest_framework import (
    status,
    mixins
)
from rest_framework.authentication import SessionAuthentication
from rest_framework.permissions import (
    AllowAny,
    IsAuthenticated
)
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
Application = get_application_model()


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


class GenerateAppCodeAPIView(APIView):
    authentication_classes = [SessionAuthentication]
    permission_classes = [IsAuthenticated]

    def get(
            self,
            request,
            *args,
            **kwargs
    ):
        if not request.user.is_authenticated:
            return Response(
                {'error': 'User not authenticated by social provider via allauth.'},
                status=status.HTTP_401_UNAUTHORIZED
            )

        app_code = str(uuid.uuid4())

        cache.set(f'django:auth:app_code:{app_code}', request.user.id, timeout=300)

        provider = request.session.get('socialaccount_sociallogin', {}).get('account', {}).get('provider')

        if not provider and request.user.socialaccount_set.exists():
            provider = request.user.socialaccount_set.first().provider

        client_callback_url_with_code = f'myapp://social-login-callback?app_code={app_code}&provider={provider}'

        return redirect(client_callback_url_with_code)


class SocialTokenExchangeAPIView(APIView):
    permission_classes = [AllowAny]

    def post(
            self,
            request,
            *args,
            **kwargs
    ):
        app_code = request.data.get('app_code')

        if not app_code:
            return Response(
                {'error': 'Application code is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        user_id = cache.get(f'django:auth:app_code:{app_code}')

        if not user_id:
            return Response(
                {'error': 'Invalid or expired application code.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        cache.delete(f'django:auth:app_code:{app_code}')

        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response(
                {'error': 'User not found for this code.'},
                status=status.HTTP_404_NOT_FOUND
            )

        try:
            application = Application.objects.get(client_id=settings.SOCIALACCOUNT_APPLICATION_CLIENT_ID)
        except Application.DoesNotExist:
            return Response(
                {'error': 'OAuth2 application for token generation not configured on Django server.'},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        expires = now() + timedelta(seconds=oauth2_settings.ACCESS_TOKEN_EXPIRE_SECONDS)
        access_token = AccessToken(
            user=user,
            application=application,
            token=generate_token(),
            expires=expires,
            scope="users:own:profile:create users:own:profile:read users:own:profile:update users:own:profile:delete achievements:own:list:read achievements:own:item:update"
        )

        access_token.save()

        refresh_token = RefreshToken(
            user=user,
            application=application,
            token=generate_token(),
            access_token=access_token
        )

        refresh_token.save()

        return Response({
            'access_token': access_token.token,
            'expires_in': oauth2_settings.ACCESS_TOKEN_EXPIRE_SECONDS,
            'token_type': 'Bearer',
            'scope': access_token.scope,
            'refresh_token': refresh_token.token
        })
