# Super Calculator

A Phoenix LiveView app that calculates Australian superannuation contributions (11.5%) in real-time as the user types, with calculation history persisted to PostgreSQL via Ecto. Deployed on Railway.

## Features

- Real-time super contribution calculation on every keystroke via `phx-change` — no page reloads
- Save and view calculation history using LiveView streams
- Input validation with inline error feedback
- PostgreSQL persistence with Ecto migrations

## Demo
<img width="1903" height="939" alt="Screenshot 2026-04-09 at 12 22 00 PM" src="https://github.com/user-attachments/assets/24284f78-51e9-4a20-b69c-ef69c79d03c7" />



## Tech Stack

- Elixir 1.19.5 / Erlang OTP 28
- Phoenix 1.8.5 with LiveView
- Ecto + PostgreSQL 14
- Deployed on Railway

## Setup

```bash
# Install dependencies
mix deps.get

# Create and migrate the database
mix ecto.create && mix ecto.migrate

# Start the server
mix phx.server
```

Visit [`localhost:4000`](http://localhost:4000).

## Deploying to Railway

1. Create a new Railway project and add a **PostgreSQL** database service
2. Add a new service from your GitHub repo
3. Set the following environment variables in your app service:

| Variable | Value |
|---|---|
| `DATABASE_URL` | Copy from the Postgres service variables |
| `SECRET_KEY_BASE` | Run `mix phx.gen.secret` locally and paste the output |
| `PHX_HOST` | Your Railway domain e.g. `yourapp.up.railway.app` |
| `PHX_SERVER` | `true` |
| `MIX_ENV` | `prod` |

4. Set the **Start Command** in Railway to run migrations before booting:

```bash
/app/bin/super_calculator eval "SuperCalculator.Release.migrate()" && /app/bin/server
```

5. Generate a public domain under **Settings → Networking → Generate Domain**, using port `4000`

## Tests

```bash
mix test
```
