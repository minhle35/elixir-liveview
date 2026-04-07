This project aims to implement a simplified version of a Phoenix LiveView App

Super Calculator
- Phoenix LiveView app
- User enters salary → calculates 11.5% super contribution in real-time
- Stores calculations in PostgreSQL with Ecto
- Basic ExUnit tests
- Deploy to Fly.io (free tier, Elixir-native)


## Setup
- This project uses ```Elixir 1.19.5 (compiled with Erlang/OTP 28```
- PostgreSQL 14.22

## Instll Phoenix generator
```
mix archive.install hex phx_new --force 2>&1
```
- This project uses Phoenix installer v1.8.5

## Create the app
```
mix phx.new elixir_liveview --app super_calculator --no-mailer 2>&1
```

## use this command to list dependencies
```
mix deps.get
```