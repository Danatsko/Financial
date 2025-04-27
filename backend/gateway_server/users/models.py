from typing import Optional

from pydantic import (
    BaseModel,
    EmailStr,
    ConfigDict
)
from datetime import datetime


class UserBase(BaseModel):
    model_config = ConfigDict(extra='ignore')

    username: str
    email: EmailStr
    balance: float
    monthly_budget: float


class UserResponseFields(UserBase):
    model_config = ConfigDict(extra='ignore', frozen=True)

    id: int
    date_joined: datetime


class TokenResponseFields(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    access_token: str
    expires_in: float
    token_type: str
    scope: str
    refresh_token: str


class PostRegistrationRequest(UserBase):
    model_config = ConfigDict(extra='ignore')

    username: Optional[str] = ""
    password: str


class PostLoginRequest(BaseModel):
    model_config = ConfigDict(extra='ignore')

    email: EmailStr
    password: str


class PostRefreshTokenRequest(BaseModel):
    model_config = ConfigDict(extra='ignore')

    refresh_token: str


class PatchMeRequest(BaseModel):
    model_config = ConfigDict(extra='ignore')

    username: Optional[str] = None
    email: Optional[EmailStr] = None
    password: Optional[str] = None
    balance: Optional[float] = None
    monthly_budget: Optional[float] = None


class PostRegistrationResponse(TokenResponseFields):
    model_config = ConfigDict(extra='ignore', frozen=True)

    pass


class PostLoginResponse(TokenResponseFields):
    model_config = ConfigDict(extra='ignore', frozen=True)

    pass


class PostRefreshTokenResponse(TokenResponseFields):
    model_config = ConfigDict(extra='ignore', frozen=True)

    pass


class PatchMeResponse(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    user: UserResponseFields


class GetMeResponse(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    user: UserResponseFields


class GetAchievementsResponse(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    achievements: dict[
        str,
        dict[
            str,
            int
        ]
    ]
