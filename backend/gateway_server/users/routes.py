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
    get_users_upstream_client
)
from users.annotations import PostRegistrationRequestBody
from users.models import PostRegistrationResponse

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
