from fastapi import (
    APIRouter,
    Depends
)
from starlette import status

from connections.redis_clients import RedisClient
from connections.upstream_clients import (
    UsersUpstreamClient,
    TransactionsUpstreamClient
)
from dependencies import (
    ensure_transactions_token_is_fresh,
    get_user_authorization_token,
    get_redis_client,
    get_transactions_upstream_client,
    get_users_upstream_client
)
from transactions.annotations import (
    PostTransactionRequestBody,
    GetDateRangeRequestParamsQuery,
    TransactionIdPath,
    PatchTransactionRequestBody,
    GetMonthlyBudgetRequestParamsQuery
)
from transactions.models import (
    PostTransactionResponse,
    GetTransactionsDataResponse,
    GetAnalyseDataResponse,
    PatchTransactionResponse,
    GetMonthlyRecommendationsResponse
)

transactions_router = APIRouter(dependencies=[Depends(ensure_transactions_token_is_fresh)])


@transactions_router.post(
    "/",
    status_code=status.HTTP_201_CREATED,
    response_model=PostTransactionResponse
)
async def post_transaction(
        transaction_data: PostTransactionRequestBody,
        user_authorization_token: str = Depends(get_user_authorization_token),
        users_client: UsersUpstreamClient = Depends(get_users_upstream_client),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    create_transaction_response = await transactions_client.post_transaction(user_id, transaction_data)

    patch_increment_achievement_value_response = await users_client.patch_increment_achievement_value(user_authorization_token, transaction_data)

    create_transaction_response_dict = create_transaction_response.json()

    return PostTransactionResponse(**create_transaction_response_dict)


@transactions_router.get(
    "/get_transactions_data/",
    status_code=status.HTTP_200_OK,
    response_model=GetTransactionsDataResponse
)
async def get_transactions_data(
        date_range: GetDateRangeRequestParamsQuery,
        user_authorization_token: str = Depends(get_user_authorization_token),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    get_transactions_data_response = await transactions_client.get_transactions_data(user_id, date_range)

    get_transactions_data_response_dict = get_transactions_data_response.json()

    return GetTransactionsDataResponse(**get_transactions_data_response_dict)


@transactions_router.get(
    "/get_analyse_data/",
    status_code=status.HTTP_200_OK,
    response_model=GetAnalyseDataResponse
)
async def get_analyse_data(
        date_range: GetDateRangeRequestParamsQuery,
        user_authorization_token: str = Depends(get_user_authorization_token),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    get_analyse_data_response = await transactions_client.get_analyse_data(user_id, date_range)

    get_analyse_data_response_dict = get_analyse_data_response.json()

    return GetAnalyseDataResponse(**get_analyse_data_response_dict)


@transactions_router.get(
    "/get_monthly_recommendations/",
    status_code=status.HTTP_200_OK,
    response_model=GetMonthlyRecommendationsResponse
)
async def get_monthly_recommendations(
        monthly_budget: GetMonthlyBudgetRequestParamsQuery,
        user_authorization_token: str = Depends(get_user_authorization_token),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    get_monthly_recommendations_response = await transactions_client.get_monthly_recommendations(user_id, monthly_budget)

    get_monthly_recommendations_response_dict = get_monthly_recommendations_response.json()

    return GetMonthlyRecommendationsResponse(**get_monthly_recommendations_response_dict)


@transactions_router.patch(
    "/{transaction_id}/",
    status_code=status.HTTP_200_OK,
    response_model=PatchTransactionResponse
)
async def patch_transaction(
        transaction_id: TransactionIdPath,
        new_transaction_data: PatchTransactionRequestBody,
        user_authorization_token: str = Depends(get_user_authorization_token),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client),
        redis_client: RedisClient = Depends(get_redis_client)
):
    user_id = await redis_client.retrieve_token_field(
        token=user_authorization_token,
        field='id'
    )

    update_transaction_response = await transactions_client.patch_transaction(transaction_id, user_id, new_transaction_data)

    update_transaction_response_dict = update_transaction_response.json()

    return PatchTransactionResponse(**update_transaction_response_dict)


@transactions_router.delete(
    "/{transaction_id}/",
    status_code=status.HTTP_204_NO_CONTENT,
    response_model=None
)
async def delete_transaction(
        transaction_id: TransactionIdPath,
        user_authorization_token: str = Depends(get_user_authorization_token),
        transactions_client: TransactionsUpstreamClient = Depends(get_transactions_upstream_client)
):
    delete_transaction_response = await transactions_client.delete_transaction(transaction_id)

    return None
