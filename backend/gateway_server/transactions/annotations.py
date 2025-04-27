from typing import Annotated

from fastapi import (
    Path,
    Body,
    Query
)

from .models import (
    GetDateRangeRequestParams,
    PostTransactionRequest,
    PatchTransactionRequest
)

TransactionIdPath = Annotated[int, Path(title='The ID of the transaction.')]
GetDateRangeRequestParamsQuery = Annotated[GetDateRangeRequestParams, Query(title='Dates between which the search takes place.')]
PostTransactionRequestBody = Annotated[PostTransactionRequest, Body(title='Data to create the transaction.')]
PatchTransactionRequestBody = Annotated[PatchTransactionRequest, Body(title='Data to update the transaction.')]
