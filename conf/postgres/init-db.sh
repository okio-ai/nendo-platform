#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE auth;
    GRANT ALL PRIVILEGES ON DATABASE auth TO nendo;
    CREATE EXTENSION IF NOT EXISTS vector;
EOSQL

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "auth" <<-EOSQL
    CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(320) NOT NULL,
        hashed_password VARCHAR(1024) NOT NULL,
        is_active BOOLEAN DEFAULT 't',
        is_superuser BOOLEAN DEFAULT 'f',
        is_verified BOOLEAN DEFAULT 'f'
    );
    INSERT INTO users (id, email, hashed_password, is_active, is_superuser, is_verified) SELECT '085df796-cb6b-4251-9d17-758c720114e5', 'dev@okio.ai', '\$2b\$12\$qHKZTet536sLeTn58AldGu32kKrHTyCABWaiYjQGZaG51eiqx5unO', 't', 't', 't' WHERE NOT EXISTS (SELECT email FROM users WHERE email = 'dev@okio.ai');
EOSQL
