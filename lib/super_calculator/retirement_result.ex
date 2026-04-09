defmodule SuperCalculator.RetirementResult do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retirement_results" do
    belongs_to :retirement_plan, SuperCalculator.RetirementPlan

    field :super_at_retirement, :decimal
    field :runway_years,        :decimal
    field :runs_out_at_age,     :integer
    field :pre60_gap_covered,   :boolean
    field :pre60_shortfall,     :decimal

    timestamps()
  end

  def changeset(result, attrs) do
    result
    |> cast(attrs, [:retirement_plan_id, :super_at_retirement, :runway_years,
                    :runs_out_at_age, :pre60_gap_covered, :pre60_shortfall])
    |> validate_required([:super_at_retirement])
    |> foreign_key_constraint(:retirement_plan_id)
  end
end
