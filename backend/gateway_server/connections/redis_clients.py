from typing import Awaitable

import redis.asyncio as redis
from redis.exceptions import (
    ConnectionError as RedisConnectionError,
    TimeoutError as RedisTimeoutError,
    RedisError
)

from exceptions.exceptions import (
    GatewayBadGatewayError,
    GatewayUnexpectedError
)


class RedisClient:
    def __init__(
            self,
            url: str,
            decode_responses: bool = True,
            **kwargs
    ):
        self._redis_client: redis.Redis | None = None
        self._url = url
        self._decode_responses = decode_responses
        self._kwargs = kwargs

    async def connect(self):
        if self._redis_client is not None:
            return

        try:
            self._redis_client = redis.Redis.from_url(
                url=self._url,
                decode_responses=self._decode_responses,
                **self._kwargs
            )

            await self._redis_client.ping()
        except (RedisConnectionError, RedisTimeoutError, ConnectionRefusedError) as e:
            self._redis_client = None

            raise GatewayBadGatewayError(service_name="Redis", error=e) from e
        except Exception:
            self._redis_client = None

            raise GatewayUnexpectedError

    async def ping(self) -> bool:
        if self._redis_client is None:
            raise GatewayUnexpectedError

        try:
            response = await self._redis_client.ping()

            return response
        except (RedisConnectionError, RedisTimeoutError) as e:
            self._redis_client = None

            raise GatewayBadGatewayError(service_name="Redis", error=e) from e
        except Exception:
            raise GatewayUnexpectedError

    async def close(self):
        if self._redis_client:
            try:
                await self._redis_client.close()
            except Exception:
                raise GatewayUnexpectedError
            finally:
                self._redis_client = None

    async def _execute_command(self, command: Awaitable):
        if self._redis_client is None:
            raise GatewayUnexpectedError

        try:
            result = await command

            return result
        except (RedisConnectionError, RedisTimeoutError) as e:
            self._redis_client = None

            raise GatewayBadGatewayError(service_name="Redis", error=e) from e
        except RedisError:
            raise GatewayUnexpectedError
        except Exception:
            self._redis_client = None

            raise GatewayUnexpectedError

    async def cache_token_data(
            self,
            token: str,
            data: dict,
            ttl: int = 3600
    ) -> None:
        key = f"fastapi:auth:token:{token}"

        await self._execute_command(self._redis_client.hset(key, mapping=data))
        await self._execute_command(self._redis_client.expire(key, ttl))

    async def retrieve_token_data(
            self,
            token: str
    ) -> dict:
        key = f"fastapi:auth:token:{token}"
        data = await self._execute_command(self._redis_client.hgetall(key))

        return data

    async def retrieve_token_field(
            self,
            token: str,
            field: str
    ) -> str:
        key = f"fastapi:auth:token:{token}"
        value = await self._execute_command(self._redis_client.hget(key, field))

        return value

    async def update_token_data(
            self,
            token: str,
            new_data: dict
    ) -> None:
        key = f"fastapi:auth:token:{token}"

        await self._execute_command(self._redis_client.hset(key, mapping=new_data))

    async def delete_token_data(
            self,
            token: str
    ) -> None:
        key = f"fastapi:auth:token:{token}"

        await self._execute_command(self._redis_client.delete(key))
