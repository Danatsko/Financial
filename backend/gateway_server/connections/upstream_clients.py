import httpx
from authlib.integrations.httpx_client import AsyncOAuth2Client
from urllib.parse import urljoin

from exceptions.exceptions import (
    GatewayUpstreamHTTPError,
    GatewayUnexpectedError,
    GatewayBadGatewayError
)
from settings import settings
from transactions.annotations import (
    PostTransactionRequestBody,
    TransactionIdPath,
    PatchTransactionRequestBody,
    GetDateRangeRequestParamsQuery
)
from users.annotations import (
    PostRegistrationRequestBody,
    PostLoginRequestBody,
    PostRefreshTokenRequestBody,
    PatchMeRequestBody
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


class UsersUpstreamClient(BaseUpstreamClient):
    @property
    def post_registration_path(self) -> str: return "users/"

    @property
    def post_login_path(self) -> str: return "o/token/"

    @property
    def post_logout_path(self) -> str: return "o/revoke_token/"

    @property
    def post_refresh_token_path(self) -> str: return "o/token/"

    @property
    def get_me_path(self) -> str: return "users/me/"

    @property
    def patch_me_path(self) -> str: return "users/me/"

    @property
    def delete_me_path(self) -> str: return "users/me/"

    @property
    def get_achievements_path(self) -> str: return "achievements/"

    @property
    def patch_increment_achievement_value_path(self) -> str: return "achievements/increment_achievement_value/"

    async def post_registration(
            self,
            user_data: PostRegistrationRequestBody
    ) -> httpx.Response:
        return await self.post(
            self.post_registration_path,
            json=user_data.model_dump()
        )

    async def post_login(
            self,
            user_data: PostLoginRequestBody
    ) -> httpx.Response:
        return await self.post(
            self.post_login_path,
            data={
                'grant_type': 'password',
                'username': user_data.email,
                'password': user_data.password,
                "scope": settings.users_server_users_scopes
            },
            auth=(settings.users_server_users_application_client_id, settings.users_server_users_application_client_secret)
        )

    async def post_logout(
            self,
            user_authorization_token: str
    ) -> httpx.Response:
        return await self.post(
            self.post_logout_path,
            data={
                'token': user_authorization_token,
                'token_type_hint': 'refresh_token'
            },
            auth=(settings.users_server_users_application_client_id, settings.users_server_users_application_client_secret)
        )

    async def post_refresh_token(
            self,
            refresh_token_data: PostRefreshTokenRequestBody
    ) -> httpx.Response:
        return await self.post(
            self.post_refresh_token_path,
            data={
                'grant_type': 'refresh_token',
                'refresh_token': refresh_token_data.refresh_token,
                "scope": settings.users_server_users_scopes
            },
            auth=(settings.users_server_users_application_client_id, settings.users_server_users_application_client_secret)
        )

    async def get_me(
            self,
            user_authorization_token: str
    ) -> httpx.Response:
        return await self.get(
            self.get_me_path,
            headers={"X-User-Authorization": f"Bearer {user_authorization_token}"}
        )

    async def patch_me(
            self,
            user_authorization_token: str,
            new_user_data: PatchMeRequestBody
    ) -> httpx.Response:
        return await self.patch(
            self.patch_me_path,
            headers={"X-User-Authorization": f"Bearer {user_authorization_token}"},
            json=new_user_data.model_dump(
                exclude_unset=True,
                exclude_none=True
            )
        )

    async def delete_me(
            self,
            user_authorization_token: str
    ) -> httpx.Response:
        return await self.delete(
            self.delete_me_path,
            headers={"X-User-Authorization": f"Bearer {user_authorization_token}"}
        )

    async def get_achievements(
            self,
            user_authorization_token: str
    ) -> httpx.Response:
        return await self.get(
            self.get_achievements_path,
            headers={"X-User-Authorization": f"Bearer {user_authorization_token}"}
        )

    async def patch_increment_achievement_value(
            self,
            user_authorization_token: str,
            transaction_data: PostTransactionRequestBody
    ) -> httpx.Response:
        return await self.patch(
            self.patch_increment_achievement_value_path,
            headers={"X-User-Authorization": f"Bearer {user_authorization_token}"},
            json={'category': transaction_data.model_dump(mode='json')['category']}
        )


class TransactionsUpstreamClient(BaseUpstreamClient):
    @property
    def post_transaction_path(self) -> str: return "transactions/"

    def patch_transaction_path(
            self,
            transaction_id: TransactionIdPath
    ) -> str:
        return f"transactions/{transaction_id}/"

    def delete_transaction_path(
            self,
            transaction_id: TransactionIdPath
    ) -> str:
        return f"transactions/{transaction_id}/"

    def get_transactions_data_path(
            self,
            user_id: str
    ) -> str:
        return f"transactions/{user_id}/get_transactions_data/"

    def get_analyse_data_path(
            self,
            user_id: str
    ) -> str:
        return f"transactions/{user_id}/get_analyse_data/"

    def get_monthly_recommendations_path(
            self,
            user_id: str
    ) -> str:
        return f"transactions/{user_id}/get_monthly_recommendations/"

    def delete_all_user_transactions_path(
            self,
            user_id: str
    ) -> str:
        return f"transactions/{user_id}/delete_all_user_transactions/"

    async def post_transaction(
            self,
            user_id: str,
            transaction_data: PostTransactionRequestBody
    ) -> httpx.Response:
        return await self.post(
            self.post_transaction_path,
            json={
                'user_id': user_id,
                **transaction_data.model_dump(mode='json')
            }
        )

    async def patch_transaction(
            self,
            transaction_id: TransactionIdPath,
            new_transaction_data: PatchTransactionRequestBody
    ) -> httpx.Response:
        return await self.patch(
            self.patch_transaction_path(transaction_id),
            json=new_transaction_data.model_dump(
                mode='json',
                exclude_unset=True,
                exclude_none=True
            )
        )

    async def delete_transaction(
            self,
            transaction_id: TransactionIdPath,
    ) -> httpx.Response:
        return await self.delete(
            self.delete_transaction_path(transaction_id),
        )

    async def get_transactions_data(
            self,
            user_id: str,
            date_range: GetDateRangeRequestParamsQuery,
    ) -> httpx.Response:
        return await self.get(
            self.get_transactions_data_path(user_id),
            params=date_range.model_dump(mode='json')
        )

    async def get_analyse_data(
            self,
            user_id: str,
            date_range: GetDateRangeRequestParamsQuery,
    ) -> httpx.Response:
        return await self.get(
            self.get_analyse_data_path(user_id),
            params=date_range.model_dump(mode='json')
        )

    async def delete_all_user_transactions(
            self,
            user_id: str,
    ) -> httpx.Response:
        return await self.delete(
            self.delete_all_user_transactions_path(user_id),
        )
