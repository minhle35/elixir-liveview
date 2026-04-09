defmodule SuperCalculator.RetirementPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "retirement_plans" do
    field :current_age,                :integer
    field :retirement_age,             :integer
    field :current_salary,             :decimal
    field :super_rate,                 :decimal, default: Decimal.new("11.5")
    field :current_super_balance,      :decimal, default: Decimal.new("0")
    field :investment_return_rate,     :decimal, default: Decimal.new("7.0")
    field :annual_spend_in_retirement, :decimal
    field :life_expectancy,            :integer, default: 85
    field :current_savings,            :decimal, default: Decimal.new("0")

    timestamps()
  end

  @required [:current_age, :retirement_age, :current_salary, :annual_spend_in_retirement]
  @optional [:super_rate, :current_super_balance, :investment_return_rate,
             :life_expectancy, :current_savings]

  def changeset(plan, attrs) do
    plan
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> validate_number(:current_age, greater_than: 0, less_than: 100)
    |> validate_number(:retirement_age, greater_than: 0, less_than: 100)
    |> validate_number(:life_expectancy, greater_than: 0, less_than: 130)
    |> validate_number(:current_salary, greater_than: 0)
    |> validate_number(:annual_spend_in_retirement, greater_than: 0)
    |> validate_number(:current_super_balance, greater_than_or_equal_to: 0)
    |> validate_number(:current_savings, greater_than_or_equal_to: 0)
    |> validate_number(:super_rate, greater_than: 0, less_than_or_equal_to: 100)
    |> validate_number(:investment_return_rate, greater_than_or_equal_to: 0)
    |> validate_retirement_age_after_current_age()
    |> validate_life_expectancy_after_retirement_age()
  end

  defp validate_retirement_age_after_current_age(changeset) do
    current = get_field(changeset, :current_age)
    retirement = get_field(changeset, :retirement_age)

    if current && retirement && retirement <= current do
      add_error(changeset, :retirement_age, "must be greater than current age")
    else
      changeset
    end
  end

  defp validate_life_expectancy_after_retirement_age(changeset) do
    retirement = get_field(changeset, :retirement_age)
    life_expectancy = get_field(changeset, :life_expectancy)

    if retirement && life_expectancy && life_expectancy <= retirement do
      add_error(changeset, :life_expectancy, "must be greater than retirement age")
    else
      changeset
    end
  end
end
