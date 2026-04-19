from collections import defaultdict
from typing import Dict, Set
from fastapi import WebSocket


class ScheduleManager:
    def __init__(self) -> None:
        self._rooms: Dict[str, Set[WebSocket]] = defaultdict(set)

    def _key(self, tuman_id: int, mahalla: str) -> str:
        return f"{tuman_id}:{mahalla.strip().lower()}"

    async def connect(self, ws: WebSocket, tuman_id: int, mahalla: str) -> str:
        await ws.accept()
        key = self._key(tuman_id, mahalla)
        self._rooms[key].add(ws)
        return key

    def disconnect(self, ws: WebSocket, key: str) -> None:
        if key in self._rooms:
            self._rooms[key].discard(ws)
            if not self._rooms[key]:
                del self._rooms[key]

    async def broadcast(self, tuman_id: int, mahalla: str, message: dict) -> None:
        key = self._key(tuman_id, mahalla)
        for ws in list(self._rooms.get(key, set())):
            await ws.send_json(message)


schedule_manager = ScheduleManager()
