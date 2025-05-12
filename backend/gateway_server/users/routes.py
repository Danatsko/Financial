from fastapi import (
    APIRouter,
    Depends
)
from starlette import status

from connections.redis_clients import RedisClient
from connections.upstream_clients import (
    UsersUpstreamClient,
    TransactionsUpstreamClient
)
from dependencies import (
    ensure_users_token_is_fresh,
    get_redis_client,
    get_users_upstream_client,
    get_user_authorization_token,
    get_transactions_upstream_client
)
from users.annotations import (
    PostRegistrationRequestBody,
    PostLoginRequestBody,
    PostRefreshTokenRequestBody,
    PatchMeRequestBody, ProviderPath
)
from users.models import (
    PostRegistrationResponse,
    PostLoginResponse,
    PostRefreshTokenResponse,
    GetMeResponse,
    PatchMeResponse,
    GetAchievementsResponse, GetSocialLoginUrlResponse
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


@users_router.post(
    "/refresh-token/",
    status_code=status.HTTP_200_OK,
    response_model=PostRefreshTokenResponse
)
async def refresh_token(
    refresh_token_data: PostRefreshTokenRequestBody,
    users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
    redis_client: RedisClient = Depends(get_redis_client)
):
    tokens_response = await users_client.post_refresh_token(refresh_token_data)

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

    return PostRefreshTokenResponse(**tokens_response_dict)


@users_router.get(
    "/me/",
    status_code=status.HTTP_200_OK,
    response_model=GetMeResponse
)
async def get_me(
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_data = await redis_client.retrieve_token_data(user_authorization_token)

    if user_data:
        return GetMeResponse(user=user_data)

    get_user_response = await users_client.get_me(user_authorization_token)

    get_user_response_dict = get_user_response.json()

    return GetMeResponse(**get_user_response_dict)


@users_router.patch(
    "/me/",
    status_code=status.HTTP_200_OK,
    response_model=PatchMeResponse
)
async def patch_user(
        new_user_data: PatchMeRequestBody,
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    update_user_response = await users_client.patch_me(user_authorization_token, new_user_data)

    update_user_response_dict = update_user_response.json()

    user_details_for_cache = None

    if update_user_response_dict and 'user' in update_user_response_dict:
        user_details_for_cache = update_user_response_dict['user']
    else:
        try:
            get_me_response = await users_client.get_me(user_authorization_token)

            get_me_response_data = get_me_response.json()

            if get_me_response_data and 'user' in get_me_response_data:
                user_details_for_cache = get_me_response_data['user']
        except Exception:
            user_details_for_cache = None

    if user_details_for_cache:
        await redis_client.update_token_data(
            token=user_authorization_token,
            new_data=user_details_for_cache,
        )

    return PatchMeResponse(**update_user_response_dict)


@users_router.delete(
    "/me/",
    status_code=status.HTTP_204_NO_CONTENT,
    response_model=None
)
async def delete_user(
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    delete_user_response = await users_client.delete_me(user_authorization_token)

    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    delete_all_user_transactions_data_response = await transactions_client.delete_all_user_transactions(user_id)

    logout_response = await users_client.post_logout(user_authorization_token)

    await redis_client.delete_token_data(token=user_authorization_token)

    return None


@users_router.get(
    "/achievements/",
    status_code=status.HTTP_200_OK,
    response_model=GetAchievementsResponse
)
async def get_achievements(
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client)
):
    get_achievements_response = await users_client.get_achievements(user_authorization_token)

    get_achievements_response_dict = get_achievements_response.json()

    return GetAchievementsResponse(**get_achievements_response_dict)


@users_router.get(
    "/social/{provider}/login-url/",
    status_code=status.HTTP_200_OK,
    response_model=GetSocialLoginUrlResponse
)
async def get_social_login_url(
        provider: str = ProviderPath,
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client)
):
    get_social_login_url_response = await users_client.get_social_login_url(provider=provider)

    get_social_login_url_response_dict = get_social_login_url_response.json()

    return GetSocialLoginUrlResponse(**get_social_login_url_response_dict)
