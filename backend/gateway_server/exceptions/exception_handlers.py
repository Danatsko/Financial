from fastapi import Request
from fastapi.responses import JSONResponse

from .exceptions import GatewayException


async def gateway_exception_handler(
        request: Request,
        exc: GatewayException
):
    return JSONResponse(
        status_code=exc.status_code,
        content={"detail": exc.detail},
        headers=exc.headers
    )
