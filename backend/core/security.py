from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from core.supabase import get_supabase
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

import httpx

SUPABASE_JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET", "")
SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_ANON_KEY", "")

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials

    # 1. Stateless network verification using ephemeral HTTP client.
    # We do THIS instead of `supabase.auth.get_user()` because the python Supabase
    # client mutates shared internal state which causes "deque mutated" concurrency crashes.
    if SUPABASE_URL and SUPABASE_KEY:
        try:
            with httpx.Client() as client:
                response = client.get(
                    f"{SUPABASE_URL}/auth/v1/user",
                    headers={
                        "apikey": SUPABASE_KEY,
                        "Authorization": f"Bearer {token}"
                    },
                    timeout=5.0
                )
            
            if response.status_code == 200:
                user_data = response.json()
                return {
                    "sub": user_data.get("id"),
                    "email": user_data.get("email"),
                }
            elif response.status_code == 401:
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired or is invalid")
        except httpx.RequestError as e:
            print(f"[Security] Stateless auth HTTP error: {e}")

    # 2. Fallback to offline JWT verification if secret exists
    if SUPABASE_JWT_SECRET:
        try:
            payload = jwt.decode(
                token,
                SUPABASE_JWT_SECRET,
                algorithms=["HS256"],
                audience="authenticated"
            )
            user_id = payload.get("sub")
            if user_id is None:
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid auth credentials")
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")
        except jwt.InvalidTokenError as e:
            print(f"[Security] JWT Decode Error: {e}")
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Unauthorized")


