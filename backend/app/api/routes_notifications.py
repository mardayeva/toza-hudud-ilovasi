from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, or_
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Notification
from app.db.session import get_db
from app.schemas.schemas import NotificationCreate, NotificationOut
from app.core.auth import require_admin_token, AdminCtx

router = APIRouter(tags=["notifications"])


@router.get("/notifications", response_model=list[NotificationOut])
async def notifications_list(
    tuman_id: int = Query(..., alias="tuman_id"),
    mahalla: str | None = Query(default=None, alias="mahalla"),
    db: AsyncSession = Depends(get_db),
):
    q = select(Notification).where(Notification.tuman_id == tuman_id)
    if mahalla:
        q = q.where(
            or_(
                Notification.mahalla == mahalla,
                Notification.mahalla.is_(None),
            )
        )
    q = q.order_by(Notification.id.desc())
    res = await db.execute(q)
    return res.scalars().all()


@router.get("/admin/notifications", response_model=list[NotificationOut])
async def notifications_list_admin(
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    q = select(Notification).order_by(Notification.id.desc())
    if admin.role != "super" and admin.tuman_id is not None:
        q = q.where(Notification.tuman_id == admin.tuman_id)
    res = await db.execute(q)
    return res.scalars().all()


@router.post("/admin/notifications", response_model=NotificationOut, status_code=201)
async def notifications_create(
    payload: NotificationCreate,
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    if admin.role != "super" and admin.tuman_id != payload.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    item = Notification(**payload.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    return item


@router.delete("/admin/notifications/{notif_id}", status_code=204)
async def notifications_delete(
    notif_id: int,
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    q = select(Notification).where(Notification.id == notif_id)
    res = await db.execute(q)
    item = res.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Not found")
    if admin.role != "super" and admin.tuman_id != item.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    await db.delete(item)
    await db.commit()
    return None
