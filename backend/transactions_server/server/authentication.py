from django.conf import settings
from django.core.exceptions import ImproperlyConfigured
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
