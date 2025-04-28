import httpx
from authlib.integrations.httpx_client import AsyncOAuth2Client
from urllib.parse import urljoin

from exceptions.exceptions import (
    GatewayUpstreamHTTPError,
    GatewayUnexpectedError,
    GatewayBadGatewayError
)


class BaseUpstreamClient:
    def __init__(
        self,
        oauth2_client: AsyncOAuth2Client,
        base_url: str
    ):
        if not isinstance(oauth2_client, AsyncOAuth2Client):
             raise TypeError("oauth2_client must be an instance of AsyncOAuth2Client")
        if not base_url:
             raise ValueError("base_url must be provided")

        self._client: AsyncOAuth2Client = oauth2_client
        self._base_url = base_url.rstrip('/') + '/'
        self._upstream_name = self.__class__.__name__

    async def ensure_token_is_fresh(self):
        if not self._client.token or self._client.token.is_expired():
            try:
                await self._client.fetch_token(grant_type="client_credentials")
            except Exception as e:
                raise GatewayUnexpectedError(f"Failed to refresh upstream service token for {self._upstream_name}") from e

    async def _send_request(
            self,
            method: str,
            path: str,
            **kwargs
    ) -> httpx.Response:
        url = urljoin(self._base_url, path.lstrip('/'))

        try:
            response = await self._client.request(method, url, **kwargs)

            response.raise_for_status()

            return response
        except httpx.RequestError as e:
            raise GatewayBadGatewayError(service_name=self._upstream_name, error=e) from e
        except httpx.HTTPStatusError as e:
            raise GatewayUpstreamHTTPError(error=e) from e
        except Exception as e:
            raise GatewayUnexpectedError(f"An unexpected error occurred during request to {self._upstream_name}") from e

    async def get(
            self,
            path: str,
            **kwargs
    ) -> httpx.Response:
         return await self._send_request("GET", path, **kwargs)

    async def post(
            self,
            path: str,
            **kwargs
    ) -> httpx.Response:
         return await self._send_request("POST", path, **kwargs)

    async def put(
            self,
            path: str,
            **kwargs
    ) -> httpx.Response:
         return await self._send_request("PUT", path, **kwargs)

    async def patch(
            self,
            path: str,
            **kwargs
    ) -> httpx.Response:
         return await self._send_request("PATCH", path, **kwargs)

    async def delete(
            self,
            path: str,
            **kwargs
    ) -> httpx.Response:
         return await self._send_request("DELETE", path, **kwargs)

    async def aclose(self):
        await self._client.aclose()
