defmodule SuperCalculator.Repo.Migrations.CreateCalculations do
  use Ecto.Migration

  def change do
    create table(:calculations) do
      add :salary, :decimal, null: false
      add :super_contribution, :decimal, null: false

      timestamps()
    end
  end
end
