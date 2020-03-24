#!/bin/sh
set -e

psql -v ON_ERROR_STOP=1 --host postgres --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
CREATE EXTENSION "uuid-ossp";
CREATE EXTENSION "pgcrypto";
EOSQL
