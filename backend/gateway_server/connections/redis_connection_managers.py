import asyncio
from datetime import timedelta

import tenacity
from aiobreaker import (
    CircuitBreaker,
    CircuitBreakerError
)

from connections.redis_clients import RedisClient
from exceptions.exceptions import (
    GatewayBadGatewayError,
    GatewayUnexpectedError
)


class RedisConnectionManager:
    def __init__(
            self,
            url: str,
            reconnect_interval: int = 60,
            circuit_breaker_fail_max: int = 3,
            circuit_breaker_reset_timeout: int = 60,
    ) -> None:
        self.url = url
        self.client: RedisClient | None = None
        self.reconnect_interval = reconnect_interval
        self.circuit_breaker = CircuitBreaker(
            fail_max=circuit_breaker_fail_max,
            timeout_duration=timedelta(seconds=circuit_breaker_reset_timeout),
        )
        self._reconnect_task: asyncio.Task | None = None

    async def start(self) -> None:
        await self._initial_connect()

        self._reconnect_task = asyncio.create_task(self._reconnect_loop())

    async def _initial_connect(self) -> None:
        try:
            self.client = RedisClient(
                url=self.url,
                decode_responses=True,
            )

            await self.client.connect()
        except Exception:
            self.client = None

    @tenacity.retry(
        wait=tenacity.wait_exponential(multiplier=1, min=2, max=10),
        stop=tenacity.stop_after_attempt(5),
        retry=tenacity.retry_if_exception_type((GatewayBadGatewayError, GatewayUnexpectedError, CircuitBreakerError))
    )
    async def _try_reconnect(self) -> None:
        try:
            self.client = RedisClient(
                url=self.url,
                decode_responses=True,
            )

            await self.client.connect()
        except Exception as e:
            self.client = None

            raise e

    async def _reconnect_loop(self) -> None:
        while True:
            if self.client is None:
                await asyncio.sleep(self.reconnect_interval)

                try:
                    await self.circuit_breaker.call_async(self._try_reconnect)
                except CircuitBreakerError:
                    pass
                except Exception:
                    pass

                await asyncio.sleep(self.reconnect_interval)
            else:
                try:
                    await self.client.ping()
                except Exception:
                    self.client = None

                await asyncio.sleep(self.reconnect_interval)

    async def get_redis_client(self) -> RedisClient:
        if self.client is None:
            raise RuntimeError("Redis client is not initialized. Connection is not established.")

        return self.client

    async def shutdown(self) -> None:
        if self._reconnect_task:
            self._reconnect_task.cancel()
        if self.client is not None:
            try:
                await self.client.close()
            except Exception:
                pass
