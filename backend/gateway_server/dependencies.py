from authlib.integrations.httpx_client import AsyncOAuth2Client
from fastapi import (
    Request,
    Depends,
    HTTPException
)
from starlette import status

from connections.redis_clients import RedisClient
from connections.redis_connection_managers import RedisConnectionManager
from connections.upstream_clients import (
    UsersUpstreamClient,
    TransactionsUpstreamClient
)
from connections.upstream_connection_managers import UpstreamConnectionManager
from settings import settings


def get_users_upstream_connection_manager(request: Request) -> UpstreamConnectionManager:
    return request.app.state.users_connection_manager


def get_transactions_upstream_connection_manager(request: Request) -> UpstreamConnectionManager:
    return request.app.state.transactions_connection_manager


def get_redis_connection_manager(request: Request) -> RedisConnectionManager:
    return request.app.state.redis_connection_manager


async def get_users_raw_oauth2_client(manager: UpstreamConnectionManager = Depends(get_users_upstream_connection_manager)) -> AsyncOAuth2Client:
    try:
        client = await manager.get_oauth2_client()

        if client is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="The service is currently unavailable. Please try again later."
            )

        return client
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="The service is currently unavailable. Please try again later."
        )


async def get_transactions_raw_oauth2_client(manager: UpstreamConnectionManager = Depends(get_transactions_upstream_connection_manager)) -> AsyncOAuth2Client:
    try:
        client = await manager.get_oauth2_client()

        if client is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="The service is currently unavailable. Please try again later."
            )

        return client
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="The service is currently unavailable. Please try again later."
        )


async def get_users_upstream_client(
    oauth2_client: AsyncOAuth2Client = Depends(get_users_raw_oauth2_client),
    users_base_url: str = str(settings.users_data_server_url)
) -> UsersUpstreamClient:
    client = UsersUpstreamClient(oauth2_client=oauth2_client, base_url=users_base_url)

    return client


async def get_transactions_upstream_client(
    oauth2_client: AsyncOAuth2Client = Depends(get_transactions_raw_oauth2_client),
    transactions_base_url: str = str(settings.transaction_server_url)
) -> TransactionsUpstreamClient:
    client = TransactionsUpstreamClient(oauth2_client=oauth2_client, base_url=transactions_base_url)

    return client


async def get_redis_client(manager: RedisConnectionManager = Depends(get_redis_connection_manager)) -> RedisClient:
    try:
        client = await manager.get_redis_client()

        if client is None:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="The service is currently unavailable. Please try again later."
            )

        return client
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="The service is currently unavailable. Please try again later."
        )
