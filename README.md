# Super Calculator

A Phoenix LiveView app that calculates Australian superannuation contributions (11.5%) in real-time as the user types, with calculation history persisted to PostgreSQL via Ecto. Deployed on Railway.

## Features

- Real-time super contribution calculation on every keystroke via `phx-change` — no page reloads
- Save and view calculation history using LiveView streams
- Input validation with inline error feedback
- PostgreSQL persistence with Ecto migrations

## Demo

https://github.com/user-attachments/assets/4909c7b7-9616-471f-a29e-afa607bc0c27

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

## Tests

```bash
mix test
```
