from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.models import Jadval, Driver, AdminUser
from app.db.session import get_db
from app.schemas.schemas import (
    JadvalCreate,
    JadvalOut,
    JadvalUpdate,
    AdminLoginIn,
    AdminLoginOut,
    DriverCreate,
    DriverOut,
    AdminUserCreate,
    AdminUserOut,
)
from app.core.auth import require_admin_token, AdminCtx
from app.core.config import settings
from app.services.auth import hash_password, make_salt, make_token
from app.ws.manager import manager
from app.ws.schedule_manager import schedule_manager

router = APIRouter(prefix="/admin", tags=["admin"])


@router.post("/login", response_model=AdminLoginOut)
async def admin_login(payload: AdminLoginIn, db: AsyncSession = Depends(get_db)):
    if (
        payload.username == settings.admin_username
        and payload.password == settings.admin_password
    ):
        return {"token": settings.admin_token, "role": "super", "tuman_id": None}

    res = await db.execute(select(AdminUser).where(AdminUser.username == payload.username))
    admin = res.scalar_one_or_none()
    if not admin:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    salt, pw = admin.password_hash.split("$")
    if hash_password(payload.password, salt) != pw:
        raise HTTPException(status_code=401, detail="Invalid credentials")
    token = make_token()
    admin.token = token
    await db.commit()
    return {"token": token, "role": admin.role, "tuman_id": admin.tuman_id}


@router.post("/admins", response_model=AdminUserOut, dependencies=[Depends(require_admin_token)])
async def admin_create(
    payload: AdminUserCreate,
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    if admin.role != "super":
        raise HTTPException(status_code=403, detail="Forbidden")
    salt = make_salt()
    pw = hash_password(payload.password, salt)
    user = AdminUser(
        username=payload.username,
        password_hash=f"{salt}${pw}",
        role=payload.role,
        tuman_id=payload.tuman_id,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.get("/admins", response_model=list[AdminUserOut], dependencies=[Depends(require_admin_token)])
async def admin_list(
    admin: AdminCtx = Depends(require_admin_token),
    db: AsyncSession = Depends(get_db),
):
    if admin.role != "super":
        raise HTTPException(status_code=403, detail="Forbidden")
    res = await db.execute(select(AdminUser).order_by(AdminUser.id.desc()))
    return res.scalars().all()


@router.post("/drivers", response_model=DriverOut, dependencies=[Depends(require_admin_token)])
async def driver_create(payload: DriverCreate, admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)):
    if admin.role != "super" and admin.tuman_id != payload.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    salt = make_salt()
    pw = hash_password(payload.password, salt)
    driver = Driver(
        full_name=payload.full_name,
        login=payload.login,
        password_hash=f"{salt}${pw}",
        vehicle_number=payload.vehicle_number,
        phone=payload.phone,
        tuman_id=payload.tuman_id,
        mahalla=payload.mahalla,
    )
    db.add(driver)
    await db.commit()
    await db.refresh(driver)
    return driver


@router.get("/drivers", response_model=list[DriverOut], dependencies=[Depends(require_admin_token)])
async def driver_list(admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)):
    q = select(Driver).order_by(Driver.id.desc())
    if admin.role != "super" and admin.tuman_id is not None:
        q = q.where(Driver.tuman_id == admin.tuman_id)
    res = await db.execute(q)
    return res.scalars().all()


@router.get("/driver-locations", dependencies=[Depends(require_admin_token)])
async def driver_locations(admin: AdminCtx = Depends(require_admin_token)):
    data = manager.get_driver_locations()
    if admin.role != "super" and admin.tuman_id is not None:
        data = [d for d in data if int(d.get("tuman_id", 0)) == admin.tuman_id]
    return {"data": data}


@router.post("/jadval", response_model=JadvalOut, status_code=201, dependencies=[Depends(require_admin_token)])
async def jadval_create(payload: JadvalCreate, admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)):
    if admin.role != "super" and admin.tuman_id != payload.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    item = Jadval(**payload.model_dump())
    db.add(item)
    await db.commit()
    await db.refresh(item)
    await schedule_manager.broadcast(
        item.tuman_id,
        item.mahalla,
        {"event": "jadval_updated", "tuman_id": item.tuman_id, "mahalla": item.mahalla},
    )
    return item


@router.get("/jadval", response_model=list[JadvalOut], dependencies=[Depends(require_admin_token)])
async def jadval_list_admin(admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)):
    q = select(Jadval).order_by(Jadval.sana, Jadval.boshlanish)
    if admin.role != "super" and admin.tuman_id is not None:
        q = q.where(Jadval.tuman_id == admin.tuman_id)
    res = await db.execute(q)
    return res.scalars().all()


@router.put("/jadval/{jadval_id}", response_model=JadvalOut, dependencies=[Depends(require_admin_token)])
async def jadval_update(
    jadval_id: int, payload: JadvalUpdate, admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)
):
    q = select(Jadval).where(Jadval.id == jadval_id)
    res = await db.execute(q)
    item = res.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Jadval topilmadi")
    if admin.role != "super" and admin.tuman_id != item.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    for k, v in payload.model_dump(exclude_unset=True).items():
        setattr(item, k, v)
    await db.commit()
    await db.refresh(item)
    await schedule_manager.broadcast(
        item.tuman_id,
        item.mahalla,
        {"event": "jadval_updated", "tuman_id": item.tuman_id, "mahalla": item.mahalla},
    )
    return item


@router.delete("/jadval/{jadval_id}", status_code=204, dependencies=[Depends(require_admin_token)])
async def jadval_delete(jadval_id: int, admin: AdminCtx = Depends(require_admin_token), db: AsyncSession = Depends(get_db)):
    q = select(Jadval).where(Jadval.id == jadval_id)
    res = await db.execute(q)
    item = res.scalar_one_or_none()
    if not item:
        raise HTTPException(status_code=404, detail="Jadval topilmadi")
    if admin.role != "super" and admin.tuman_id != item.tuman_id:
        raise HTTPException(status_code=403, detail="Forbidden")
    await db.delete(item)
    await db.commit()
    await schedule_manager.broadcast(
        item.tuman_id,
        item.mahalla,
        {"event": "jadval_updated", "tuman_id": item.tuman_id, "mahalla": item.mahalla},
    )
    return None
