from typing import Annotated

from fastapi import (
    Body,
    Header,
    Path
)

from .models import (
    PatchMeRequest,
    PostRegistrationRequest,
    PostLoginRequest,
    PostRefreshTokenRequest,
    PostSocialExchangeTokenRequest
)

ProviderPath = Annotated[str, Path(title='The name of the social provider.')]
AuthHeader = Annotated[str, Header(title='The user authorization token.', alias='Authorization')]
PatchMeRequestBody = Annotated[PatchMeRequest, Body(title='Data to update the user.')]
PostRegistrationRequestBody = Annotated[PostRegistrationRequest, Body(title='Data to register the user.')]
PostLoginRequestBody = Annotated[PostLoginRequest, Body(title='Data to login the user.')]
PostRefreshTokenRequestBody = Annotated[PostRefreshTokenRequest, Body(title='Data to refresh the token.')]
PostSocialExchangeTokenRequestParamsBody = Annotated[PostSocialExchangeTokenRequest, Body(title='Parameters for social token exchange.')]
