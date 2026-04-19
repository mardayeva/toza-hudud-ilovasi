from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Driver
from app.db.session import get_db
from app.schemas.schemas import DriverLoginIn, DriverAuthOut
from app.services.auth import hash_password, make_token

router = APIRouter(tags=["auth"])


@router.post("/driver/login", response_model=DriverAuthOut)
async def driver_login(payload: DriverLoginIn, db: AsyncSession = Depends(get_db)):
    res = await db.execute(select(Driver).where(Driver.login == payload.login))
    driver = res.scalar_one_or_none()
    if not driver:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    salt, pw = driver.password_hash.split("$")
    if hash_password(payload.password, salt) != pw:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = make_token()
    driver.token = token
    await db.commit()
    return {
        "token": token,
        "driver_id": driver.id,
        "full_name": driver.full_name,
        "vehicle_number": driver.vehicle_number,
        "tuman_id": driver.tuman_id,
        "mahalla": driver.mahalla,
    }
