from typing import Optional

from pydantic import (
    BaseModel,
    model_validator,
    ConfigDict
)
from datetime import datetime


class TransactionBase(BaseModel):
    model_config = ConfigDict(extra='ignore')

    type: str
    amount: float
    title: str
    payment_method: str
    description: str
    category: str
    creation_date: datetime


class TransactionResponseFields(TransactionBase):
    model_config = ConfigDict(extra='ignore', frozen=True)

    id: int
    user_id: int


class AnalyseCategoryDetailsResponseFields(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    percentage: float
    transactions: list[TransactionResponseFields]


class AnalyseTypeDetailsResponseFields(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    total_amount: float
    categories: dict[
        str,
        AnalyseCategoryDetailsResponseFields
    ]


class RecommendationInsightResponseFields(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    status: str
    data: dict[
        str,
        str | float | int | list[str]
    ]


class PostTransactionRequest(TransactionBase):
    model_config = ConfigDict(extra='ignore')

    pass


class PatchTransactionRequest(BaseModel):
    model_config = ConfigDict(extra='ignore')

    type: Optional[str] = None
    amount: Optional[float] = None
    title: Optional[str] = None
    payment_method: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    creation_date: Optional[datetime] = None


class GetDateRangeRequestParams(BaseModel):
    model_config = ConfigDict(extra='ignore')

    start_date: datetime
    end_date: datetime

    @model_validator(mode='before')
    def check_date_range(
            cls,
            values
    ):
        start_date = values.get("start_date")
        end_date = values.get("end_date")

        if start_date is not None and end_date is not None and start_date > end_date:
            raise ValueError("start_date cannot be greater than end_date")

        return values


class GetMonthlyBudgetRequestParams(BaseModel):
    model_config = ConfigDict(extra='ignore')

    monthly_budget: float


class PostTransactionResponse(TransactionResponseFields):
    model_config = ConfigDict(extra='ignore', frozen=True)

    pass


class PatchTransactionResponse(TransactionResponseFields):
    model_config = ConfigDict(extra='ignore', frozen=True)

    pass


class GetTransactionsDataResponse(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    transactions: list[TransactionResponseFields]
    detail: Optional[str] = None


class GetAnalyseDataResponse(BaseModel):
    model_config = ConfigDict(extra='ignore', frozen=True)

    time_data: dict[
        str,
        dict[
            datetime,
            float
        ]
    ]
    type_data: dict[
        str,
        AnalyseTypeDetailsResponseFields
    ]
    detail: Optional[str] = None
