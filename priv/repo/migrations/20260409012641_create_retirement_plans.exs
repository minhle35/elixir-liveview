defmodule SuperCalculator.Repo.Migrations.CreateRetirementPlans do
  use Ecto.Migration

  def change do
    create table(:retirement_plans) do
      add :current_age,                :integer, null: false
      add :retirement_age,             :integer, null: false
      add :current_salary,             :decimal, null: false
      add :super_rate,                 :decimal, null: false, default: "11.5"
      add :current_super_balance,      :decimal, null: false, default: "0"
      add :investment_return_rate,     :decimal, null: false, default: "7.0"
      add :annual_spend_in_retirement, :decimal, null: false
      add :life_expectancy,            :integer, null: false, default: 85
      add :current_savings,            :decimal, null: false, default: "0"

      timestamps()
    end
  end
end
