from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select, text
from sqlalchemy.exc import ProgrammingError
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import AppUser, Driver
from app.db.session import get_db
from app.schemas.schemas import (
    UserRegisterIn,
    UserLoginIn,
    UserAuthOut,
    DriverLoginIn,
    DriverAuthOut,
)
from app.services.auth import hash_password, make_salt, make_token
from app.core.config import settings

router = APIRouter(tags=["auth"])

async def _ensure_username_column(db: AsyncSession) -> None:
    if not settings.database_url.startswith("postgresql"):
        return
    await db.execute(text("ALTER TABLE app_user ADD COLUMN IF NOT EXISTS username VARCHAR(50)"))
    await db.execute(text("UPDATE app_user SET username = COALESCE(username, full_name) WHERE username IS NULL"))
    await db.execute(text("CREATE UNIQUE INDEX IF NOT EXISTS app_user_username_uq ON app_user(username)"))
    await db.commit()

@router.post("/auth/register", response_model=UserAuthOut)
async def register(payload: UserRegisterIn, db: AsyncSession = Depends(get_db)):
    try:
        existing = await db.execute(select(AppUser).where(AppUser.username == payload.username))
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=400, detail="Username already registered")
    except ProgrammingError:
        await _ensure_username_column(db)
        existing = await db.execute(select(AppUser).where(AppUser.username == payload.username))
        if existing.scalar_one_or_none():
            raise HTTPException(status_code=400, detail="Username already registered")

    salt = make_salt()
    pw = hash_password(payload.password, salt)
    token = make_token()

    user = AppUser(
        username=payload.username,
        full_name=payload.full_name,
        password_hash=f"{salt}${pw}",
        token=token,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return {"token": token, "user_id": user.id, "full_name": user.full_name}


@router.post("/auth/login", response_model=UserAuthOut)
async def login(payload: UserLoginIn, db: AsyncSession = Depends(get_db)):
    try:
        res = await db.execute(select(AppUser).where(AppUser.username == payload.username))
        user = res.scalar_one_or_none()
    except ProgrammingError:
        await _ensure_username_column(db)
        res = await db.execute(select(AppUser).where(AppUser.username == payload.username))
        user = res.scalar_one_or_none()
    if not user:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    salt, pw = user.password_hash.split("$")
    if hash_password(payload.password, salt) != pw:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = make_token()
    user.token = token
    await db.commit()
    return {"token": token, "user_id": user.id, "full_name": user.full_name}


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
