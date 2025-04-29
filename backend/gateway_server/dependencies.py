from fastapi import Request

from connections.redis_connection_managers import RedisConnectionManager
from connections.upstream_connection_managers import UpstreamConnectionManager


def get_users_upstream_connection_manager(request: Request) -> UpstreamConnectionManager:
    return request.app.state.users_connection_manager


def get_transactions_upstream_connection_manager(request: Request) -> UpstreamConnectionManager:
    return request.app.state.transactions_connection_manager


def get_redis_connection_manager(request: Request) -> RedisConnectionManager:
    return request.app.state.redis_connection_manager
