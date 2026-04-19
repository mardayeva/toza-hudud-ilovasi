from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.api.router import api_router
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from app.db.base import Base
from app.db.session import engine
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
        # driver new columns for sqlite/postgres
        for stmt in [
            "ALTER TABLE jadval ADD COLUMN driver_id INTEGER",
            "ALTER TABLE driver ADD COLUMN phone VARCHAR(30)",
            "ALTER TABLE driver ADD COLUMN tuman_id INTEGER",
            "ALTER TABLE driver ADD COLUMN mahalla VARCHAR(120)",
            "ALTER TABLE shikoyat ADD COLUMN tuman_id INTEGER",
            "ALTER TABLE shikoyat ADD COLUMN javob VARCHAR(600)",
        ]:
            try:
                await conn.execute(text(stmt))
            except SQLAlchemyError:
                pass


app.include_router(api_router, prefix=settings.api_prefix)
app.include_router(ws_router)
