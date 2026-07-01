# ADR 001: JWT authentication (not Keycloak)

## Status

Accepted — internship project (June 2026)

## Context

KickPro needs stateless authentication for a **single mobile client + REST API**. Users have roles (`PLAYER`, `SCOUT`, `AGENT`, `ADMIN`). We considered:

- **Custom JWT** (Spring Security + `JwtUtil` + `JwtAuthFilter`)
- **Keycloak** (OIDC / OAuth2 identity provider)

## Decision

Use **stateless JWT** issued at login/register:

1. `AuthServiceImpl` signs tokens with `JwtUtil` (HS256, secret from `JWT_SECRET`).
2. `JwtAuthFilter` reads `Authorization: Bearer <token>`, validates, loads `User`, sets Spring Security context.
3. `@EnableMethodSecurity` + role checks on admin/scout endpoints.
4. WebSocket STOMP uses the same JWT at connection time.

No external IdP for v1.

## Consequences

- **Pros:** Simple Docker stack; no extra service; fast for a stage project; easy to explain in demos.
- **Cons:** No SSO, no social login, manual token revocation (logout = client discards token until expiry).
- **Security notes:** Secret must be strong in prod; tokens expire (`jwt.expiration-ms`, default 24h).

## Alternatives considered

| Option | Why not (for now) |
|--------|-------------------|
| **Keycloak** | Extra container, realm setup, overkill for one app and one team |
| **Session cookies** | Poor fit for Flutter mobile + stateless API |
| **OAuth2 only (Google)** | Out of scope for academic MVP |

## Revisit when

Multi-app SSO, enterprise clients, or fine-grained policy UI is required.
