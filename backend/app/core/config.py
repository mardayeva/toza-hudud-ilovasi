from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    app_name: str = "ChiqindiNav Backend"
    api_prefix: str = "/v1"
    database_url: str = "sqlite+aiosqlite:///./chiqindi_nav.db"
    cors_origins: list[str] = ["*"]
    redis_url: str = "redis://localhost:6379/0"
    admin_token: str = "changeme"
    admin_username: str = "admin"
    admin_password: str = "admin123"

    class Config:
        env_prefix = "CHIQINDI_"
        env_file = ".env"
        env_file_encoding = "utf-8"


settings = Settings()
