from django.core.exceptions import ImproperlyConfigured
from rest_framework.permissions import BasePermission
from oauth2_provider.models import AccessToken


class GatewayTokenMatchesOASRequirements(BasePermission):
    def has_permission(self, request, view):
        token = getattr(request, 'gateway_auth', None)

        if not isinstance(token, AccessToken) or not hasattr(token, 'scope'):
            return False

        required_gateway_alternate_scopes = self.get_required_gateway_alternate_scopes(request, view)

        method = request.method.upper()

        if method in required_gateway_alternate_scopes:
            for alt_scope_list in required_gateway_alternate_scopes[method]:
                if token.is_valid(alt_scope_list):
                    return True

            return False
        else:
            return False

    def get_required_gateway_alternate_scopes(self, request, view):
        try:
            return getattr(view, "required_gateway_alternate_scopes")
        except AttributeError:
            raise ImproperlyConfigured(
                f"{self.__class__.__name__} requires the view {view.__class__.__name__} to"
                f" define the 'required_gateway_alternate_scopes' attribute."
            )
