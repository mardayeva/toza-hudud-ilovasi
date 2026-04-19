from fastapi import APIRouter

from app.api.routes_health import router as health_router
from app.api.routes_jadval import router as jadval_router
from app.api.routes_shikoyat import router as shikoyat_router
from app.api.routes_admin import router as admin_router
from app.api.routes_auth import router as auth_router
from app.api.routes_regions import router as regions_router
from app.api.routes_notifications import router as notifications_router

api_router = APIRouter()
api_router.include_router(health_router)
api_router.include_router(jadval_router)
api_router.include_router(shikoyat_router)
api_router.include_router(admin_router)
api_router.include_router(auth_router)
api_router.include_router(regions_router)
api_router.include_router(notifications_router)
