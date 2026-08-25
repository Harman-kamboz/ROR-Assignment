# SaaS Marketplace (Rails API)

Ruby on Rails 8.1 API for a multi-tenant SaaS marketplace: companies, products, global clients with per-company overlays, and orders.

See [DESIGN.md](DESIGN.md) for architecture notes.

## Requirements

- Ruby **3.3.6+** (see `.ruby-version`)
- PostgreSQL 14+
- Bundler

## Setup

```bash
cd "/home/invinsible/ROR Assignment"
bundle install
```

### Database

`config/database.yml` defaults to:

- host: `127.0.0.1`
- port: `5433`
- username: `invinsible`

If you use the system Postgres cluster instead, set env vars:

```bash
export DATABASE_HOST=127.0.0.1
export DATABASE_PORT=5432
export DATABASE_USERNAME=your_user
export DATABASE_PASSWORD=your_password
```

Create and migrate:

```bash
bin/rails db:create db:migrate
```

### Optional: user-space Postgres (no sudo)

If your OS Postgres has no role for your user:

```bash
export PGDATA="$HOME/.local/pgsql/data"
mkdir -p "$HOME/.local/pgsql/run"
# after initdb once, start with:
/usr/lib/postgresql/14/bin/pg_ctl -D "$PGDATA" -l "$HOME/.local/pgsql/logfile" start
```

## Run

```bash
bin/rails server
```

API base: `http://localhost:3000/api/v1`

## Test

```bash
bin/rails test
```

## Example requests

### 1. Company signup (creates company + admin)

```bash
curl -s -X POST http://localhost:3000/api/v1/signup \
  -H 'Content-Type: application/json' \
  -d '{"name":"Ada Admin","email":"ada@acme.com","password":"secret12","company_name":"Acme Inc"}'
```

Save the returned `token`.

### 2. Create a product

```bash
TOKEN=... # admin JWT

curl -s -X POST http://localhost:3000/api/v1/products \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Widget","description":"Useful widget","price":"19.99"}'
```

### 3. Create a company client (phone only → dummy email hidden)

```bash
curl -s -X POST http://localhost:3000/api/v1/clients \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Phone Customer","phone":"9000000001"}'
```

Response `email` is `null` even though the DB stores `user_<uuid>@noemail.com`.

### 4. Marketplace client register + order

```bash
curl -s -X POST http://localhost:3000/api/v1/clients/register \
  -H 'Content-Type: application/json' \
  -d '{"name":"Buyer","email":"buyer@example.com","password":"secret12"}'

CLIENT_TOKEN=...

curl -s http://localhost:3000/api/v1/marketplace/products

curl -s -X POST http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer $CLIENT_TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"product_id":1,"quantity":2}'
```

### 5. Company lists orders

```bash
curl -s http://localhost:3000/api/v1/orders \
  -H "Authorization: Bearer $TOKEN"
```

## Main endpoints

| Method | Path | Auth | Description |
| --- | --- | --- | --- |
| POST | `/api/v1/signup` | — | Create company + admin |
| POST | `/api/v1/login` | — | Admin login |
| POST | `/api/v1/clients/register` | — | Global client signup |
| POST | `/api/v1/clients/login` | — | Client login |
| GET/POST | `/api/v1/products` | User | Company products |
| GET/POST/PATCH | `/api/v1/clients` | User | Company clients (overlay) |
| GET | `/api/v1/orders` | User or Client | Company or client orders |
| GET | `/api/v1/marketplace/products` | — | Catalog |
| POST | `/api/v1/orders` | Client | Place order |
| GET | `/api/v1/my/orders` | Client | Client order history |
