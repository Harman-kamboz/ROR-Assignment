# SaaS Marketplace — Design Note

## Overview

This API implements a multi-tenant SaaS marketplace where **companies** sell **products**, and **clients** can buy from many companies. The design separates a single global client identity from each company’s local CRM view of that person.

## Core models

| Model | Role |
| --- | --- |
| `User` | Company admin (created with the company on signup) |
| `Company` | Tenant boundary |
| `Product` | Belongs to one company |
| `Client` | Global marketplace identity |
| `CompanyClient` | Per-company overlay of client data |
| `Order` | Purchase; stores `company_id` for isolation |

```text
User ──belongs_to──▶ Company ◀──has_many── Product
                       │                      │
                       │                      │
                       ▼                      ▼
                 CompanyClient ◀── Order ──▶ Client (global)
```

## Global client vs company overlay

`Client` is the shared identity used for marketplace login and cross-company matching.

`CompanyClient` stores that company’s own copy of name / email / phone. Updates to `CompanyClient` **never** write back to `Client`. That meets the requirement: the same person can appear differently at each company without corrupting the global record.

On a client’s first purchase from a company, a `CompanyClient` row is created automatically (seeded from the global client) so the company can see the buyer in their client list.

## Matching by email or phone

When a company creates a client:

1. Require at least one of email or phone.
2. Look up an existing global `Client` by email **or** phone.
3. If email and phone resolve to **different** clients, reject with `422`.
4. If a match exists, attach / refresh only `CompanyClient`.
5. If not, create a new global `Client`, then `CompanyClient`.

Marketplace registration (`POST /api/v1/clients/register`) creates a global client only — no company attachment until they buy or a company imports them.

## Dummy email contract

The `clients.email` column is `NOT NULL`. If input has no email, the service stores:

`user_<uuid>@noemail.com`

API serializers never expose these addresses. `EmailPresenter.public_email` returns `null` when the value matches the dummy pattern. Company-facing responses use `CompanyClient` display helpers, which also hide dummy emails when falling back to the global row.

## Tenant isolation

Every company-scoped endpoint authenticates a `User` JWT and scopes queries with `current_user.company_id`:

- Products, company clients, and company orders are never loaded across tenants.
- Guessing another company’s resource id returns `404`, not the foreign record.
- `Order.company_id` is denormalized from the product’s company at purchase time so company order lists stay simple and safe.

## Authentication

JWT (`HS256`) with payload `{ sub, type: "User"|"Client", company_id? }`.

- Company admins: `POST /api/v1/signup`, `POST /api/v1/login`
- Marketplace clients: `POST /api/v1/clients/register`, `POST /api/v1/clients/login`

Passwords use `has_secure_password` (bcrypt). Company-created CRM clients may have no password until they register on the marketplace separately.

## Order flow

1. Client authenticates and lists catalog: `GET /api/v1/marketplace/products`
2. Client places order: `POST /api/v1/orders` with `product_id` and `quantity`
3. Service validates product, ensures `CompanyClient`, snapshots `unit_price`, creates `Order`
4. Company lists its orders: `GET /api/v1/orders` (User JWT)
5. Client lists their orders: `GET /api/v1/my/orders` (Client JWT)

## API surface (summary)

- Auth / signup as above
- Company: products CRUD-lite, clients CRUD-lite, orders index
- Marketplace: product catalog, place order, my orders

Error responses use `{ "errors": ["..."] }`. Dummy emails never appear in successful payloads.
