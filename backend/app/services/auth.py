import hashlib
import secrets


def hash_password(password: str, salt: str) -> str:
    return hashlib.sha256((salt + password).encode("utf-8")).hexdigest()


def make_salt() -> str:
    return secrets.token_hex(8)


def make_token() -> str:
    return secrets.token_urlsafe(32)
