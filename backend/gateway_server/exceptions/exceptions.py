from fastapi import (
    HTTPException,
    status
)
from fastapi.encoders import jsonable_encoder
import httpx
import json


class GatewayException(HTTPException):
    def __init__(
            self,
            status_code: int,
            detail: any = None,
            headers: dict | None = None
    ):
        super().__init__(
            status_code=status_code,
            detail=jsonable_encoder(detail),
            headers=headers
        )


class GatewayBadGatewayError(GatewayException):
    def __init__(
            self,
            service_name: str,
            error: httpx.RequestError
    ):
        super().__init__(
            status_code=status.HTTP_502_BAD_GATEWAY,
            detail=f"Unable to connect to {service_name} server."
        )


class GatewayUpstreamHTTPError(GatewayException):
    def __init__(
            self,
            error: httpx.HTTPStatusError
    ):
        detail = None

        try:
            detail = error.response.json()
        except json.JSONDecodeError:
             detail = error.response.text

        super().__init__(
            status_code=error.response.status_code,
            detail=detail
        )


class GatewayUnexpectedError(GatewayException):
    def __init__(
            self,
            error: Exception
    ):
        super().__init__(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred."
        )
