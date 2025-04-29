from fastapi import (
    APIRouter,
    Depends
)

from dependencies import ensure_transactions_token_is_fresh

transactions_router = APIRouter(dependencies=[Depends(ensure_transactions_token_is_fresh)])
