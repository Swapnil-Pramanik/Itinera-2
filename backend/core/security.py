from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from core.supabase import get_supabase
import jwt
import os
from dotenv import load_dotenv

load_dotenv()

SUPABASE_JWT_SECRET = os.environ.get("SUPABASE_JWT_SECRET", "")

security = HTTPBearer()

def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)):
    token = credentials.credentials

    # Primary: Use Supabase's own auth.get_user() to verify the token.
    # This doesn't require a local JWT secret.
    try:
        supabase = get_supabase()
        user_response = supabase.auth.get_user(token)
        if user_response and user_response.user:
            return {
                "sub": user_response.user.id,
                "email": user_response.user.email,
            }
    except Exception as e:
        print(f"[Security] Supabase auth.get_user failed: {e}")

    # Fallback: Local JWT decode (requires SUPABASE_JWT_SECRET in .env)
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
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid authentication credentials")
            return payload
        except jwt.ExpiredSignatureError:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired")
        except jwt.InvalidTokenError:
            pass

    raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")

