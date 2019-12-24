# TcelferApi <sub>[t]cel-fer</sub> #
### Track your mood from day to day, API edition ###
-- --

#### Database config ####
 1. `mv config/tc_api.{sample-,}dev.yml`
 2. create a postgresql db, user.
    - Also enable the following Pgsql extensions.
        - This will go away eventually. But for now..
        - `$POSTGRES_USER` needs to be able to enable extensions on `$TCELFER_DB`
        ```sh
        psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$TCELFER_DB" <<-EOSQL
        CREATE EXTENSION "uuid-ossp";
        EOSQL
        ```
 3. set creds in `config/tc_api.ENV.yml`

#### Usage ####
- `bundle install`
- `bundle exec rackup`
