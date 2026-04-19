from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.router import api_router
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from app.db.base import Base
from app.db.session import engine
from app.core.config import settings
from app.ws.routes_ws import router as ws_router

app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def on_startup():
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
        # lightweight migrations
        try:
            await conn.execute(text("ALTER TABLE app_user ADD COLUMN username VARCHAR(50)"))
        except SQLAlchemyError:
            pass
        try:
            await conn.execute(text("UPDATE app_user SET username = COALESCE(username, full_name) WHERE username IS NULL"))
        except SQLAlchemyError:
            pass
        try:
            await conn.execute(text("CREATE UNIQUE INDEX IF NOT EXISTS app_user_username_uq ON app_user(username)"))
        except SQLAlchemyError:
            pass
        # driver new columns for sqlite/postgres
        for stmt in [
            "ALTER TABLE jadval ADD COLUMN driver_id INTEGER",
            "ALTER TABLE driver ADD COLUMN phone VARCHAR(30)",
            "ALTER TABLE driver ADD COLUMN tuman_id INTEGER",
            "ALTER TABLE driver ADD COLUMN mahalla VARCHAR(120)",
            "ALTER TABLE shikoyat ADD COLUMN tuman_id INTEGER",
        ]:
            try:
                await conn.execute(text(stmt))
            except SQLAlchemyError:
                pass


app.include_router(api_router, prefix=settings.api_prefix)
app.include_router(ws_router)
