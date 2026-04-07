defmodule SuperCalculator.Calculations do
  import Ecto.Query
  alias SuperCalculator.{Repo, Calculation}

  @super_rate Decimal.new("0.115")

  def compute_super(salary) when is_binary(salary) do
    case Decimal.parse(salary) do
      {amount, ""} -> {:ok, Decimal.mult(amount, @super_rate)}
      _ -> {:error, :invalid}
    end
  end

  def save_calculation(salary_str) do
    with {:ok, super_contribution} <- compute_super(salary_str),
         {salary, ""} <- Decimal.parse(salary_str) do
      %Calculation{}
      |> Calculation.changeset(%{salary: salary, super_contribution: super_contribution})
      |> Repo.insert()
    else
      _ -> {:error, :invalid}
    end
  end

  def list_calculations do
    Calculation
    |> order_by(desc: :inserted_at)
    |> limit(10)
    |> Repo.all()
  end
end
