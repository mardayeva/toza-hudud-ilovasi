from datetime import datetime
from pydantic import BaseModel


class JadvalBase(BaseModel):
    tuman_id: int
    tuman: str
    mahalla: str
    sana: str
    boshlanish: str
    tugash: str
    holat: str = "keladi"
    driver_id: int | None = None
    mashina_raqam: str | None = None
    haydovchi_ism: str | None = None


class JadvalCreate(JadvalBase):
    pass


class JadvalUpdate(BaseModel):
    sana: str | None = None
    boshlanish: str | None = None
    tugash: str | None = None
    holat: str | None = None
    driver_id: int | None = None
    mashina_raqam: str | None = None
    haydovchi_ism: str | None = None


class JadvalOut(JadvalBase):
    id: int

    class Config:
        from_attributes = True


class ShikoyatCreate(BaseModel):
    tuman_id: int | None = None
    tuman: str
    mahalla: str
    xil: str
    izoh: str
    lat: float | None = None
    lon: float | None = None


class ShikoyatOut(ShikoyatCreate):
    id: int
    holat: str
    created_at: datetime

    class Config:
        from_attributes = True


class HealthOut(BaseModel):
    status: str


class NotificationCreate(BaseModel):
    tuman_id: int
    mahalla: str | None = None
    title: str
    body: str
    level: str = "info"


class NotificationOut(NotificationCreate):
    id: int
    created_at: datetime

    class Config:
        from_attributes = True


class AdminLoginIn(BaseModel):
    username: str
    password: str


class AdminLoginOut(BaseModel):
    token: str
    role: str
    tuman_id: int | None = None


class AdminUserCreate(BaseModel):
    username: str
    password: str
    role: str = "tuman"
    tuman_id: int | None = None


class AdminUserOut(BaseModel):
    id: int
    username: str
    role: str
    tuman_id: int | None = None

    class Config:
        from_attributes = True


class UserRegisterIn(BaseModel):
    username: str
    full_name: str
    password: str


class UserLoginIn(BaseModel):
    username: str
    password: str


class UserAuthOut(BaseModel):
    token: str
    user_id: int
    full_name: str


class DriverCreate(BaseModel):
    full_name: str
    login: str
    password: str
    vehicle_number: str
    phone: str | None = None
    tuman_id: int | None = None
    mahalla: str | None = None


class DriverOut(BaseModel):
    id: int
    full_name: str
    login: str
    vehicle_number: str
    phone: str | None = None
    tuman_id: int | None = None
    mahalla: str | None = None

    class Config:
        from_attributes = True


class DriverLoginIn(BaseModel):
    login: str
    password: str


class DriverAuthOut(BaseModel):
    token: str
    driver_id: int
    full_name: str
    vehicle_number: str
    tuman_id: int | None = None
    mahalla: str | None = None
