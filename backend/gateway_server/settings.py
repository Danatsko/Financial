from pydantic import AnyHttpUrl
from pydantic_settings import (
    BaseSettings,
    SettingsConfigDict
)


class Settings(BaseSettings):
    model_config = SettingsConfigDict()

    users_server_url: AnyHttpUrl
    users_server_gateway_application_client_id: str
    users_server_gateway_application_client_secret: str
    users_server_users_application_client_id: str
    users_server_users_application_client_secret: str
    users_server_gateway_scopes: str
    users_server_users_scopes: str

    transactions_server_url: AnyHttpUrl
    transactions_server_gateway_application_client_id: str
    transactions_server_gateway_application_client_secret: str
    transactions_server_gateway_scopes: str

    redis_server_host: str
    redis_server_port: int
    redis_server_db: int


settings = Settings()
