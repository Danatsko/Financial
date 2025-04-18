from django.conf import settings
from django.core.exceptions import ImproperlyConfigured
from oauth2_provider.models import AccessToken
from rest_framework.authentication import BaseAuthentication
from rest_framework.exceptions import AuthenticationFailed
from oauth2_provider.contrib.rest_framework import OAuth2Authentication


class GatewayTokenAuthentication(OAuth2Authentication):
    def authenticate(self, request):
        auth_tuple = super().authenticate(request)

        if auth_tuple is None:
            return None

        user, token = auth_tuple

        if not hasattr(token, 'application') or not token.application:
            raise AuthenticationFailed('Server token is not associated with any application.')

        if not hasattr(settings, 'GATEWAY_APPLICATION_CLIENT_IDS'):
            raise ImproperlyConfigured("Setting 'GATEWAY_APPLICATION_CLIENT_IDS' is not defined.")

        if not isinstance(settings.GATEWAY_APPLICATION_CLIENT_IDS, (list, tuple)):
            raise ImproperlyConfigured("Setting 'GATEWAY_APPLICATION_CLIENT_IDS' must be a list or tuple.")

        if token.application.client_id not in settings.GATEWAY_APPLICATION_CLIENT_IDS:
            raise AuthenticationFailed('Invalid server token: incorrect client application.')

        request.gateway_auth = token

        return auth_tuple


class GatewayAndClientTokenAuthentication(BaseAuthentication):
    def authenticate(self, request):
        gateway_authenticator = OAuth2Authentication()
        gateway_auth_tuple = gateway_authenticator.authenticate(request)

        if gateway_auth_tuple is None:
            raise AuthenticationFailed('Invalid or missing gateway token.')

        gateway_user, gateway_token = gateway_auth_tuple

        if not hasattr(gateway_token, 'application') or not gateway_token.application:
            raise AuthenticationFailed('Gateway token is not associated with any application.')

        if not hasattr(settings, 'GATEWAY_APPLICATION_CLIENT_IDS'):
            raise ImproperlyConfigured("Setting 'GATEWAY_APPLICATION_CLIENT_IDS' is not defined.")

        if not isinstance(settings.GATEWAY_APPLICATION_CLIENT_IDS, (list, tuple)):
            raise ImproperlyConfigured("Setting 'GATEWAY_APPLICATION_CLIENT_IDS' must be a list or tuple.")

        if gateway_token.application.client_id not in settings.GATEWAY_APPLICATION_CLIENT_IDS:
            raise AuthenticationFailed('Invalid gateway token: incorrect client application.')

        request.gateway_auth = gateway_token

        client_header = request.META.get('HTTP_X_USER_AUTHORIZATION')

        if not client_header:
            raise AuthenticationFailed('Client token header (X-User-Authorization) is missing.')

        parts = client_header.split()

        if len(parts) != 2 or parts[0].lower() != 'bearer':
            raise AuthenticationFailed("Invalid X-User-Authorization header format. Expected 'Bearer <token>'.")

        client_token_value = parts[1]

        try:
            client_token = AccessToken.objects.select_related('user', 'application').get(token=client_token_value)
        except AccessToken.DoesNotExist:
            raise AuthenticationFailed('Invalid client token.')

        if client_token.is_expired():
            raise AuthenticationFailed('Client token is expired.')

        if not client_token.user:
            raise AuthenticationFailed('Client token is not associated with a user.')

        if not hasattr(client_token, 'application') or not client_token.application:
            raise AuthenticationFailed('Client token is not associated with any application.')

        if not hasattr(settings, 'ALLOWED_USER_CLIENT_IDS'):
            raise ImproperlyConfigured("Setting 'ALLOWED_USER_CLIENT_IDS' is not defined.")

        if not isinstance(settings.ALLOWED_USER_CLIENT_IDS, (list, tuple)):
            raise ImproperlyConfigured("Setting 'ALLOWED_USER_CLIENT_IDS' must be a list or tuple.")

        if client_token.application.client_id not in settings.ALLOWED_USER_CLIENT_IDS:
            raise AuthenticationFailed('Invalid client token: incorrect client application.')

        request.client_auth = client_token

        return (client_token.user, client_token)
