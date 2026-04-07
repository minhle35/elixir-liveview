defmodule SuperCalculator.Calculation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calculations" do
    field :salary, :decimal
    field :super_contribution, :decimal

    timestamps()
  end

  def changeset(calculation, attrs) do
    calculation
    |> cast(attrs, [:salary, :super_contribution])
    |> validate_required([:salary, :super_contribution])
    |> validate_number(:salary, greater_than: 0)
  end
end
