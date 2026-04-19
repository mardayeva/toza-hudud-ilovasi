from fastapi import APIRouter, WebSocket, WebSocketDisconnect, Query
from sqlalchemy import select

from app.db.models import Driver
from app.db.session import AsyncSessionLocal

from app.ws.manager import manager
from app.ws.schedule_manager import schedule_manager
from app.ws.notification_manager import notification_manager

router = APIRouter()


@router.websocket("/ws/mashina")
async def ws_mashina(
    ws: WebSocket,
    tuman_id: int = Query(...),
    mahalla: str = Query(...),
):
    key = await manager.connect(ws, tuman_id, mahalla)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        manager.disconnect(ws, key)


@router.websocket("/ws/driver")
async def ws_driver(ws: WebSocket):
    await ws.accept()
    try:
        while True:
            data = await ws.receive_json()
            token = data.get("token")
            if not token:
                continue
            async with AsyncSessionLocal() as db:
                res = await db.execute(select(Driver).where(Driver.token == token))
                driver = res.scalar_one_or_none()
            if not driver:
                continue
            tuman_id = int(data.get("tuman_id"))
            mahalla = data.get("mahalla")
            if not mahalla:
                continue
            data["driver"] = driver.full_name
            data["raqam"] = driver.vehicle_number
            data["driver_id"] = driver.id
            data["ts"] = data.get("ts") or ""
            manager.set_driver_location(driver.id, data)
            await manager.broadcast(tuman_id, mahalla, data)
    except WebSocketDisconnect:
        return


@router.websocket("/ws/jadval")
async def ws_jadval(
    ws: WebSocket,
    tuman_id: int = Query(...),
    mahalla: str = Query(...),
):
    key = await schedule_manager.connect(ws, tuman_id, mahalla)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        schedule_manager.disconnect(ws, key)


@router.websocket("/ws/notifications")
async def ws_notifications(
    ws: WebSocket,
    tuman_id: int = Query(...),
    mahalla: str | None = Query(default=None),
):
    keys = await notification_manager.connect(ws, tuman_id, mahalla)
    try:
        while True:
            await ws.receive_text()
    except WebSocketDisconnect:
        notification_manager.disconnect(ws, keys)
