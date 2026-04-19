from dataclasses import dataclass
from fastapi import Header, HTTPException
from sqlalchemy import select

from app.core.config import settings
from app.db.models import AdminUser
from app.db.session import AsyncSessionLocal


@dataclass
class AdminCtx:
    role: str
    tuman_id: int | None
    token: str


async def require_admin_token(
    x_admin_token: str | None = Header(default=None),
) -> AdminCtx:
    if not x_admin_token:
        raise HTTPException(status_code=401, detail="Unauthorized")

    if settings.admin_token and x_admin_token == settings.admin_token:
        return AdminCtx(role="super", tuman_id=None, token=x_admin_token)

    async with AsyncSessionLocal() as db:
        res = await db.execute(select(AdminUser).where(AdminUser.token == x_admin_token))
        admin = res.scalar_one_or_none()
        if not admin:
            raise HTTPException(status_code=401, detail="Unauthorized")
        return AdminCtx(role=admin.role, tuman_id=admin.tuman_id, token=x_admin_token)
