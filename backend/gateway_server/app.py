from fastapi import (
    FastAPI,
    APIRouter
)

from transactions.routes import transactions_router
from users.routes import users_router

app = FastAPI()

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
