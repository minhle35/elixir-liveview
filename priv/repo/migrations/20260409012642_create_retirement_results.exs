defmodule SuperCalculator.Repo.Migrations.CreateRetirementResults do
  use Ecto.Migration

  def change do
    create table(:retirement_results) do
      add :retirement_plan_id,  references(:retirement_plans, on_delete: :delete_all), null: false
      add :super_at_retirement, :decimal, null: false
      add :runway_years,        :decimal
      add :runs_out_at_age,     :integer
      add :pre60_gap_covered,   :boolean
      add :pre60_shortfall,     :decimal

      timestamps()
    end

    create index(:retirement_results, [:retirement_plan_id])
  end
end
