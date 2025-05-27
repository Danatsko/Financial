from contextlib import asynccontextmanager

from fastapi import (
    FastAPI,
    APIRouter
)

from connections.redis_connection_managers import RedisConnectionManager
from connections.upstream_connection_managers import UpstreamConnectionManager
from exceptions.exception_handlers import gateway_exception_handler
from exceptions.exceptions import GatewayException
from settings import settings
from transactions.routes import transactions_router
from users.routes import users_router


@asynccontextmanager
async def app_lifespan(app: FastAPI):
    users_connection_manager = UpstreamConnectionManager(
        manager_name="Users manager connections",
        client_id=settings.users_server_gateway_application_client_id,
        client_secret=settings.users_server_gateway_application_client_secret,
        base_url=str(settings.users_server_url),
        token_endpoint=f"{settings.users_server_url}/o/token/",
        scope=settings.users_server_gateway_scopes
    )

    transactions_connection_manager = UpstreamConnectionManager(
        manager_name="Transactions manager connections",
        client_id=settings.transactions_server_gateway_application_client_id,
        client_secret=settings.transactions_server_gateway_application_client_secret,
        base_url=str(settings.transactions_server_url),
        token_endpoint=f"{settings.transactions_server_url}/o/token/",
        scope=settings.transactions_server_gateway_scopes
    )

    redis_connection_manager = RedisConnectionManager(
        url=settings.redis_server_url
    )

    app.state.users_connection_manager = users_connection_manager
    app.state.transactions_connection_manager = transactions_connection_manager
    app.state.redis_connection_manager = redis_connection_manager

    await users_connection_manager.start()
    await transactions_connection_manager.start()
    await redis_connection_manager.start()

    try:
        yield
    finally:
        await users_connection_manager.shutdown()
        await transactions_connection_manager.shutdown()
        await redis_connection_manager.shutdown()

app = FastAPI(lifespan=app_lifespan)

app.add_exception_handler(GatewayException, gateway_exception_handler)

api_router = APIRouter(prefix="/api")

api_router.include_router(
    users_router,
    prefix="/users",
    tags=["users"]
)
api_router.include_router(
    transactions_router,
    prefix="/transactions",
    tags=["transactions"]
)

app.include_router(api_router)
