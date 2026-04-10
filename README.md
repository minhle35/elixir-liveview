# Super Calculator — Retirement Planner

A Phoenix LiveView web app that helps Australians answer a critical retirement question:

> **"If I retire at age X with $Y in super, will I run out of money before I die?"**

Users enter their financial details and get real-time answers — no page reloads, no form submissions.

---

## What does this app do?

The planner models retirement in two phases:

### Phase 1 — Accumulation (working years → retirement)
Calculates how much superannuation you will have accumulated by retirement, based on:
- Your current super balance growing at an investment return rate
- Annual employer contributions (salary × super rate) compounding over time

### Phase 2 — Drawdown (retirement → end of life)
Given the super balance at retirement, calculates how long it will last given your annual living expenses. Answers:
- How many years of income does your super provide?
- At what age does it run out?
- Or — does it outlast your life expectancy?

### Early Retirement (age < 60)
In Australia, super is inaccessible before age 60 (preservation age). If you plan to retire early, the app checks whether your personal savings can cover living expenses during the gap years before super becomes available.

---

## Data Modelling

### Inputs

| Field | Description | Default |
|---|---|---|
| Current age | Your age today | — |
| Retirement age | Age you plan to stop working | — |
| Annual salary | Gross income per year | — |
| Super rate | Employer contribution rate | 11.5% |
| Current super balance | What you have in super today | 0 |
| Investment return rate | Expected annual growth on super | 7.0% |
| Annual spend in retirement | Living expenses per year in retirement | — |
| Life expectancy | Used to determine if super outlasts you | 85 |
| Personal savings | Required only for early retirement (age < 60) | 0 |

### Formulas

**Phase 1 — Future Value (accumulation):**
```
FV = P(1 + r)^n + C × ((1 + r)^n - 1) / r

P = current super balance
r = annual investment return rate (decimal)
n = years until retirement
C = annual contribution (salary × super rate)
```

**Phase 2 — Runway (drawdown):**
```
n = -log(1 - (balance × r) / annual_spend) / log(1 + r)

n = years until super is depleted
```
Returns `nil` (money never runs out) when `balance × r ≥ annual_spend`.

**Early retirement gap check:**
```
total_needed = annual_spend × (60 - retirement_age)
gap_covered  = current_savings ≥ total_needed
```

### Assumptions
- Constant salary (no raises modelled)
- Constant investment return rate (no market volatility)
- Annual contributions and withdrawals (not monthly)
- No tax modelling
- No Age Pension modelling

---

## Demo

<img width="1903" height="939" alt="Screenshot 2026-04-09 at 12 22 00 PM" src="https://github.com/user-attachments/assets/24284f78-51e9-4a20-b69c-ef69c79d03c7" />

---

## Tech Stack

### Language & Runtime
| Technology | Version | Purpose |
|---|---|---|
| Elixir | 1.19.5 | Primary language — functional, concurrent, runs on the BEAM VM |
| Erlang OTP | 28 | Underlying runtime — provides fault-tolerant process model |

### Web Framework
| Technology | Version | Purpose |
|---|---|---|
| Phoenix | 1.8.5 | Web framework — routing, controllers, HTTP pipeline |
| Phoenix LiveView | 1.1.0 | Real-time UI — server-rendered reactive components, no JavaScript needed |
| Bandit | 1.5 | HTTP server (replaces Cowboy) |

### Data
| Technology | Version | Purpose |
|---|---|---|
| Ecto | 3.13 | Database wrapper and query DSL |
| Ecto SQL | 3.13 | SQL adapter layer |
| Postgrex | latest | PostgreSQL driver |
| PostgreSQL | 14 | Database (schemas exist, persistence currently disabled) |
| Decimal | — | Precise decimal arithmetic for financial calculations |

### Frontend
| Technology | Version | Purpose |
|---|---|---|
| Tailwind CSS | 0.3 | Utility-first CSS framework |
| DaisyUI | — | Tailwind component library (cards, alerts, buttons) |
| Heroicons | 2.2.0 | SVG icon set |
| esbuild | 0.10 | JavaScript bundler |

### Observability & Tooling
| Technology | Purpose |
|---|---|
| Phoenix LiveDashboard | Real-time metrics dashboard at `/dev/dashboard` |
| Telemetry + Telemetry Metrics | Application metrics and instrumentation |
| Gettext | Internationalisation support |
| ExUnit | Elixir's built-in test framework |

### Infrastructure
| Technology | Purpose |
|---|---|
| Railway | Cloud deployment platform |
| GitHub Actions | CI — runs tests on every push and PR |

---

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

---

## Deploying to Railway

1. Create a new Railway project and add a **PostgreSQL** database service
2. Add a new service from your GitHub repo
3. Set the following environment variables in your app service:

| Variable | Value |
|---|---|
| `SECRET_KEY_BASE` | Run `mix phx.gen.secret` locally and paste the output |
| `PHX_HOST` | Your Railway domain e.g. `yourapp.up.railway.app` |
| `PHX_SERVER` | `true` |
| `MIX_ENV` | `prod` |

4. Set the **Start Command** in Railway to run migrations before booting:

```bash
/app/bin/super_calculator eval "SuperCalculator.Release.migrate()" && /app/bin/server
```

5. Generate a public domain under **Settings → Networking → Generate Domain**, using port `4000`

---

## Tests

```bash
mix test
```
