import asyncio
import os
import sys

import asyncpg
from passlib.context import CryptContext

# Create a password context for bcrypt hashing
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

db_user = os.getenv("POSTGRES_USER")
db_password = os.getenv("POSTGRES_PASSWORD")
db_name = "auth"
db_host = os.getenv("POSTGRES_HOST")

async def update_user_password(user_id, new_password):
    # Hash the new password
    hashed_password = pwd_context.hash(new_password)

    # Connect to your database
    conn = await asyncpg.connect(user=db_user, password=db_password, database=db_name, host=db_host)

    # Update the user's password
    await conn.execute(
        "UPDATE users SET hashed_password = $1 WHERE id = $2",
        hashed_password, user_id,
    )

    print(f"Password updated for user {user_id}")

    # Close the connection
    await conn.close()

if __name__ == "__main__":
    user_id = "085df796-cb6b-4251-9d17-758c720114e5"  # User ID to update
    new_password = sys.argv[1] if len(sys.argv) > 1 else "defaultPassword"

    asyncio.run(update_user_password(user_id, new_password))
