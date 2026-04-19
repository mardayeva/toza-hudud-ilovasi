from fastapi import APIRouter
from app.data.regions import TUMANLAR

router = APIRouter(tags=["regions"])


@router.get("/regions")
async def regions():
    return {"tumanlar": TUMANLAR}
