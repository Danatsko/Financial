import asyncio
from datetime import timedelta

import tenacity
from aiobreaker import (
    CircuitBreaker,
    CircuitBreakerError
)
from authlib.integrations.httpx_client import AsyncOAuth2Client

from exceptions.exceptions import (
    GatewayUnexpectedError,
    GatewayBadGatewayError
)


class UpstreamConnectionManager:
    def __init__(
            self,
            manager_name: str,
            client_id: str,
            client_secret: str,
            token_endpoint: str,
            scope: str,
            base_url: str,
            reconnect_interval: int = 60,
            circuit_breaker_fail_max: int = 3,
            circuit_breaker_reset_timeout: int = 60
    ) -> None:
        self.manager_name = manager_name
        self.client_id = client_id
        self.client_secret = client_secret
        self.token_endpoint = token_endpoint
        self.scope = scope
        self.base_url = base_url
        self.oauth_client: AsyncOAuth2Client | None = None
        self.reconnect_interval = reconnect_interval
        self.circuit_breaker = CircuitBreaker(
            fail_max=circuit_breaker_fail_max,
            timeout_duration=timedelta(seconds=circuit_breaker_reset_timeout)
        )
        self._reconnect_task: asyncio.Task | None = None

    async def start(self) -> None:
        await self._initial_connect()

        self._reconnect_task = asyncio.create_task(self._reconnect_loop())

    async def _initial_connect(self) -> None:
        try:
            self.oauth_client = AsyncOAuth2Client(
                client_id=self.client_id,
                client_secret=self.client_secret,
                scope=self.scope,
                token_endpoint=self.token_endpoint,
                base_url=self.base_url
            )

            await self.oauth_client.fetch_token(grant_type='client_credentials')
        except Exception:
            self.oauth_client = None

    @tenacity.retry(
        wait=tenacity.wait_exponential(multiplier=1, min=2, max=10),
        stop=tenacity.stop_after_attempt(5),
        retry=tenacity.retry_if_exception_type((GatewayBadGatewayError, GatewayUnexpectedError, CircuitBreakerError))
    )
    async def _try_reconnect(self) -> None:
        client = AsyncOAuth2Client(
            client_id=self.client_id,
            client_secret=self.client_secret,
            scope=self.scope,
            token_endpoint=self.token_endpoint,
            base_url=self.base_url
        )

        await client.fetch_token(grant_type='client_credentials')

        self.oauth_client = client

    async def _reconnect_loop(self) -> None:
        while True:
            if self.oauth_client is None:
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
                    response = await self.oauth_client.get("health/", params={'format': 'json'})

                    response.raise_for_status()
                except Exception:
                    self.oauth_client = None

                await asyncio.sleep(self.reconnect_interval)

    async def get_oauth2_client(self) -> AsyncOAuth2Client:
        if self.oauth_client is None:
            raise RuntimeError("OAuth2 client is not initialized. Connection is not established.")

        return self.oauth_client

    async def shutdown(self) -> None:
        if self._reconnect_task:
            self._reconnect_task.cancel()
        if self.oauth_client is not None:
            try:
                await self.oauth_client.revoke_token(
                    url=f"{self.base_url}/o/revoke_token/",
                    token=self.oauth_client.token["access_token"]
                )

                await self.oauth_client.aclose()
            except Exception:
                pass
