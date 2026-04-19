from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Shikoyat
from app.db.session import get_db
from app.schemas.schemas import ShikoyatCreate, ShikoyatOut
from app.core.auth import require_admin_token, AdminCtx

router = APIRouter(tags=["shikoyat"])


@router.post("/shikoyat", response_model=ShikoyatOut, status_code=201)
async def shikoyat_create(payload: ShikoyatCreate, db: AsyncSession = Depends(get_db)):
    item = Shikoyat(**payload.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


@router.get("/admin/shikoyat", response_model=list[ShikoyatOut])
async def shikoyat_list(
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    q = select(Shikoyat).order_by(Shikoyat.id.desc())
    if admin.role != "super" and admin.tuman_id is not None:
        q = q.where(Shikoyat.tuman_id == admin.tuman_id)
    res = await db.execute(q)
    return res.scalars().all()
