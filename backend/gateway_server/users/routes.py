from fastapi import (
    APIRouter,
    Depends
)
from starlette import status

from connections.redis_clients import RedisClient
from connections.upstream_clients import UsersUpstreamClient
from dependencies import (
    ensure_users_token_is_fresh,
    get_redis_client,
    get_users_upstream_client,
    get_user_authorization_token
)
from users.annotations import (
    PostRegistrationRequestBody,
    PostLoginRequestBody
)
from users.models import (
    PostRegistrationResponse,
    PostLoginResponse
)

users_router = APIRouter(dependencies=[Depends(ensure_users_token_is_fresh)])


@users_router.post(
    "/registration/",
    status_code=status.HTTP_201_CREATED,
    response_model=PostRegistrationResponse
)
async def registration(
        user_data: PostRegistrationRequestBody,
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    registration_response = await users_client.post_registration(user_data)

    tokens_response = await users_client.post_login(user_data)

    access_token = tokens_response.json()['access_token']

    user_data_response = await users_client.get_me(access_token)

    await redis_client.cache_token_data(
        token=tokens_response.json()['access_token'],
        data=user_data_response.json()['user'],
        ttl=tokens_response.json()['expires_in']
    )

    tokens_response_dict = tokens_response.json()

    return PostRegistrationResponse(**tokens_response_dict)


@users_router.post(
    "/login/",
    status_code=status.HTTP_200_OK,
    response_model=PostLoginResponse
)
async def login(
        user_data: PostLoginRequestBody,
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    tokens_response = await users_client.post_login(user_data)

    access_token = tokens_response.json()['access_token']
    expires_in = tokens_response.json()['expires_in']

    user_data_response = await users_client.get_me(access_token)

    user = user_data_response.json()['user']

    await redis_client.cache_token_data(
        token=access_token,
        data=user,
        ttl=expires_in
    )

    tokens_response_dict = tokens_response.json()

    return PostLoginResponse(**tokens_response_dict)


@users_router.post(
    "/logout/",
    status_code=status.HTTP_204_NO_CONTENT,
    response_model=None
)
async def logout(
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    logout_response = await users_client.post_logout(user_authorization_token)

    await redis_client.delete_token_data(token=user_authorization_token)

    return None
