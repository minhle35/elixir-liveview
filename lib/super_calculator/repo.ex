defmodule SuperCalculator.Repo do
  use Ecto.Repo,
    otp_app: :super_calculator,
    adapter: Ecto.Adapters.Postgres
end
