from collections import defaultdict
from typing import Dict, Set

from fastapi import WebSocket


class NotificationManager:
    def __init__(self) -> None:
        self._rooms: Dict[str, Set[WebSocket]] = defaultdict(set)

    def _key(self, tuman_id: int, mahalla: str | None = None) -> str:
        mahalla_key = "*" if not mahalla else mahalla.strip().lower()
        return f"{tuman_id}:{mahalla_key}"

    async def connect(self, ws: WebSocket, tuman_id: int, mahalla: str | None = None) -> list[str]:
        await ws.accept()
        keys = [self._key(tuman_id)]
        if mahalla:
            keys.append(self._key(tuman_id, mahalla))
        for key in keys:
            self._rooms[key].add(ws)
        return keys

    def disconnect(self, ws: WebSocket, keys: list[str]) -> None:
        for key in keys:
            if key in self._rooms:
                self._rooms[key].discard(ws)
                if not self._rooms[key]:
                    del self._rooms[key]

    async def broadcast(self, tuman_id: int, mahalla: str | None, message: dict) -> None:
        targets = set(self._rooms.get(self._key(tuman_id), set()))
        if mahalla:
            targets.update(self._rooms.get(self._key(tuman_id, mahalla), set()))
        for ws in list(targets):
            await ws.send_json(message)


notification_manager = NotificationManager()
