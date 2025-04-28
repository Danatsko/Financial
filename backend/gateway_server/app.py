from fastapi import (
    FastAPI,
    APIRouter
)

from exceptions.exception_handlers import gateway_exception_handler
from exceptions.exceptions import GatewayException
from transactions.routes import transactions_router
from users.routes import users_router

app = FastAPI()

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
