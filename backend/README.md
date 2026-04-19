# ChiqindiNav Backend

## Ishga tushirish

1) Virtual env yarating va kutubxonalarni o'rnating:

```
python -m venv .venv
.\.venv\Scripts\activate
pip install -r requirements.txt
```

2) Serverni ishga tushiring:

```
uvicorn app.main:app --reload --port 8000
```

## Muhim sozlamalar

- `CHIQINDI_DATABASE_URL` (PostgreSQL uchun)
- `CHIQINDI_REDIS_URL` (Redis uchun)
- `CHIQINDI_ADMIN_TOKEN` (admin API uchun token)
- `CHIQINDI_ADMIN_USERNAME` (admin login)
- `CHIQINDI_ADMIN_PASSWORD` (admin parol)

## Admin rollari

- Super admin: `CHIQINDI_ADMIN_USERNAME` / `CHIQINDI_ADMIN_PASSWORD`
- Tuman admin: super admin orqali yaratiladi (`/v1/admin/admins`)

Misol:

```
set CHIQINDI_DATABASE_URL=postgresql+asyncpg://user:pass@localhost:5432/chiqindi
set CHIQINDI_REDIS_URL=redis://localhost:6379/0
set CHIQINDI_ADMIN_TOKEN=supersecret
set CHIQINDI_ADMIN_USERNAME=admin
set CHIQINDI_ADMIN_PASSWORD=admin123
```

## WebSocket

- Foydalanuvchi kuzatuvi: `ws://localhost:8000/ws/mashina?tuman_id=1&mahalla=...`
- Haydovchi GPS yuborishi: `ws://localhost:8000/ws/driver`
