from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Jadval
from app.db.session import get_db
from app.schemas.schemas import JadvalOut

router = APIRouter(tags=["jadval"])


@router.get("/jadval")
async def jadval_list(
    tuman_id: int | None = Query(None, alias="tuman_id"),
    mahalla: str | None = Query(None, alias="mahalla"),
    driver_id: int | None = Query(None, alias="driver_id"),
    db: AsyncSession = Depends(get_db),
):
    if driver_id is not None:
        q = (
            select(Jadval)
            .where(Jadval.driver_id == driver_id)
            .order_by(Jadval.sana, Jadval.boshlanish)
        )
    else:
        if tuman_id is None or mahalla is None:
            raise HTTPException(status_code=400, detail="tuman_id and mahalla are required")
        q = (
            select(Jadval)
            .where(Jadval.tuman_id == tuman_id)
            .where(Jadval.mahalla == mahalla)
            .order_by(Jadval.sana, Jadval.boshlanish)
        )
    res = await db.execute(q)
    items = res.scalars().all()
    return {"data": items}
