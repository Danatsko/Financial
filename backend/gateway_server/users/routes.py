from fastapi import (
    APIRouter,
    Depends
)

from dependencies import ensure_users_token_is_fresh

users_router = APIRouter(dependencies=[Depends(ensure_users_token_is_fresh)])
