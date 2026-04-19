from datetime import datetime
from sqlalchemy import DateTime, Integer, String, Float, func
from sqlalchemy.orm import Mapped, mapped_column

from app.db.base import Base


class Jadval(Base):
    __tablename__ = "jadval"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    tuman_id: Mapped[int] = mapped_column(Integer, index=True)
    tuman: Mapped[str] = mapped_column(String(120))
    mahalla: Mapped[str] = mapped_column(String(120), index=True)
    sana: Mapped[str] = mapped_column(String(10))
    boshlanish: Mapped[str] = mapped_column(String(5))
    tugash: Mapped[str] = mapped_column(String(5))
    holat: Mapped[str] = mapped_column(String(20), default="keladi")
    driver_id: Mapped[int | None] = mapped_column(Integer, nullable=True, index=True)
    mashina_raqam: Mapped[str | None] = mapped_column(String(32), nullable=True)
    haydovchi_ism: Mapped[str | None] = mapped_column(String(120), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class Shikoyat(Base):
    __tablename__ = "shikoyat"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    tuman_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    tuman: Mapped[str] = mapped_column(String(120))
    mahalla: Mapped[str] = mapped_column(String(120))
    xil: Mapped[str] = mapped_column(String(50))
    izoh: Mapped[str] = mapped_column(String(500))
    javob: Mapped[str | None] = mapped_column(String(600), nullable=True)
    lat: Mapped[float | None] = mapped_column(Float, nullable=True)
    lon: Mapped[float | None] = mapped_column(Float, nullable=True)
    holat: Mapped[str] = mapped_column(String(30), default="yuborildi")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class Driver(Base):
    __tablename__ = "driver"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    full_name: Mapped[str] = mapped_column(String(120))
    login: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(128))
    vehicle_number: Mapped[str] = mapped_column(String(32))
    token: Mapped[str | None] = mapped_column(String(128), nullable=True)
    phone: Mapped[str | None] = mapped_column(String(30), nullable=True)
    tuman_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    mahalla: Mapped[str | None] = mapped_column(String(120), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class AdminUser(Base):
    __tablename__ = "admin_user"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    username: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String(128))
    role: Mapped[str] = mapped_column(String(20), default="tuman")
    tuman_id: Mapped[int | None] = mapped_column(Integer, nullable=True)
    token: Mapped[str | None] = mapped_column(String(128), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )


class Notification(Base):
    __tablename__ = "notification"

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    tuman_id: Mapped[int] = mapped_column(Integer, index=True)
    mahalla: Mapped[str | None] = mapped_column(String(120), nullable=True)
    title: Mapped[str] = mapped_column(String(200))
    body: Mapped[str] = mapped_column(String(600))
    level: Mapped[str] = mapped_column(String(30), default="info")
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), server_default=func.now()
    )
