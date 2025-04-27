from typing import Annotated

from fastapi import (
    Body,
    Header,
)

from .models import (
    PatchMeRequest,
    PostRegistrationRequest,
    PostLoginRequest,
    PostRefreshTokenRequest
)

AuthHeader = Annotated[str, Header(title='The user authorization token.', alias='Authorization')]
PatchMeRequestBody = Annotated[PatchMeRequest, Body(title='Data to update the user.')]
PostRegistrationRequestBody = Annotated[PostRegistrationRequest, Body(title='Data to register the user.')]
PostLoginRequestBody = Annotated[PostLoginRequest, Body(title='Data to login the user.')]
PostRefreshTokenRequestBody = Annotated[PostRefreshTokenRequest, Body(title='Data to refresh the token.')]
