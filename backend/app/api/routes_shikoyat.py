from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Shikoyat
from app.db.session import get_db
from app.schemas.schemas import ShikoyatCreate, ShikoyatOut, ShikoyatReplyIn
from app.core.auth import require_admin_token, AdminCtx
from app.db.models import Notification
from app.ws.notification_manager import notification_manager

router = APIRouter(tags=["shikoyat"])


@router.post("/shikoyat", response_model=ShikoyatOut, status_code=201)
async def shikoyat_create(payload: ShikoyatCreate, db: AsyncSession = Depends(get_db)):
    item = Shikoyat(**payload.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    notice = Notification(
        tuman_id=item.tuman_id or 0,
        mahalla=item.mahalla,
        title="Shikoyat qabul qilindi",
        body=f"{item.mahalla} bo'yicha '{item.xil}' shikoyatingiz saqlandi.",
        level="info",
    )
    db.add(notice)
    await db.commit()
    await db.refresh(notice)
    if item.tuman_id is not None:
        await notification_manager.broadcast(
            item.tuman_id,
            item.mahalla,
            {
                "event": "complaint_created",
                "id": notice.id,
                "tuman_id": notice.tuman_id,
                "mahalla": notice.mahalla,
                "title": notice.title,
                "body": notice.body,
                "level": notice.level,
                "created_at": notice.created_at.isoformat() if notice.created_at else None,
            },
        )
    return item


@router.post("/admin/shikoyat/{shikoyat_id}/javob", response_model=ShikoyatOut)
async def shikoyat_reply(
    shikoyat_id: int,
    payload: ShikoyatReplyIn,
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    q = select(Shikoyat).where(Shikoyat.id == shikoyat_id)
    res = await db.execute(q)
    item = res.scalar_one_or_none()
    if not item:
        from fastapi import HTTPException

        raise HTTPException(status_code=404, detail="Not found")
    if admin.role != "super" and admin.tuman_id is not None and item.tuman_id is not None:
        if admin.tuman_id != item.tuman_id:
            from fastapi import HTTPException

            raise HTTPException(status_code=403, detail="Forbidden")

    item.javob = payload.javob
    item.holat = "javob berildi"
    db.add(item)
    await db.commit()
    await db.refresh(item)

    notice = Notification(
        tuman_id=item.tuman_id or 0,
        mahalla=item.mahalla,
        title="Shikoyatingizga javob bor",
        body=payload.javob,
        level="success",
    )
    db.add(notice)
    await db.commit()
    await db.refresh(notice)

    if item.tuman_id is not None:
        await notification_manager.broadcast(
            item.tuman_id,
            item.mahalla,
            {
                "event": "complaint_reply",
                "id": notice.id,
                "tuman_id": notice.tuman_id,
                "mahalla": notice.mahalla,
                "title": notice.title,
                "body": notice.body,
                "level": notice.level,
                "created_at": notice.created_at.isoformat() if notice.created_at else None,
            },
        )
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
