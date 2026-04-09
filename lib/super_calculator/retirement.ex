defmodule SuperCalculator.Retirement do
  alias SuperCalculator.{Repo, RetirementPlan, RetirementResult}

  @doc """
  Validates inputs and computes the full retirement result without persisting.
  Returns {:ok, %RetirementResult{}} or {:error, changeset}.
  """
  def compute_all(attrs) do
    changeset = RetirementPlan.changeset(%RetirementPlan{}, attrs)

    with {:ok, plan} <- Ecto.Changeset.apply_action(changeset, :validate) do
      {:ok, do_compute(plan)}
    end
  end

  # NOTE: save_plan/1 is intentionally unused in the current deployment.
  # For budget reasons, we keep the app stateless — no DB persistence for retirement plans.
  # This function is retained for future use if persistence is needed.
  @doc """
  Validates, persists the plan and result in a transaction.
  Returns {:ok, {plan, result}} or {:error, changeset}.
  """
  def save_plan(attrs) do
    changeset = RetirementPlan.changeset(%RetirementPlan{}, attrs)

    case Ecto.Changeset.apply_action(changeset, :validate) do
      {:error, cs} ->
        {:error, cs}

      {:ok, _} ->
        Repo.transaction(fn ->
          plan = Repo.insert!(changeset)
          result = do_compute(plan)

          result_attrs = %{
            retirement_plan_id: plan.id,
            super_at_retirement: result.super_at_retirement,
            runway_years: result.runway_years,
            runs_out_at_age: result.runs_out_at_age,
            pre60_gap_covered: result.pre60_gap_covered,
            pre60_shortfall: result.pre60_shortfall
          }

          persisted = Repo.insert!(RetirementResult.changeset(%RetirementResult{}, result_attrs))
          {plan, persisted}
        end)
    end
  end

  @doc """
  Phase 1: Compound growth of current super balance plus annual contributions.
  FV = P(1+r)^n + C * ((1+r)^n - 1) / r
  """
  def compute_accumulation(%RetirementPlan{} = plan) do
    p = to_float(plan.current_super_balance)
    r = plan.investment_return_rate |> Decimal.div(100) |> to_float()
    n = plan.retirement_age - plan.current_age
    c = plan.current_salary |> Decimal.mult(Decimal.div(plan.super_rate, 100)) |> to_float()

    fv =
      if r == 0.0 do
        p + c * n
      else
        growth = :math.pow(1 + r, n)
        p * growth + c * (growth - 1) / r
      end

    fv |> Float.round(2) |> Decimal.from_float()
  end

  @doc """
  Phase 2: How long does the super balance last given annual withdrawals?
  n = -log(1 - (balance * r) / spend) / log(1 + r)
  Returns {runway_years, runs_out_at_age} or {nil, nil} if balance outlasts life expectancy.
  """
  def compute_drawdown(super_at_retirement, %RetirementPlan{} = plan) do
    balance = to_float(super_at_retirement)
    r = plan.investment_return_rate |> Decimal.div(100) |> to_float()
    spend = to_float(plan.annual_spend_in_retirement)
    max_years = plan.life_expectancy - plan.retirement_age

    runway_years =
      cond do
        balance <= 0.0 ->
          0.0

        spend <= 0.0 ->
          nil

        r == 0.0 ->
          balance / spend

        # Returns exceed withdrawals — balance sustains indefinitely
        balance * r >= spend ->
          nil

        true ->
          numerator = 1 - balance * r / spend
          -:math.log(numerator) / :math.log(1 + r)
      end

    case runway_years do
      nil ->
        {nil, nil}

      years when years >= max_years ->
        {nil, nil}

      years ->
        runs_out = plan.retirement_age + trunc(Float.ceil(years))
        {years |> Float.round(1) |> Decimal.from_float(), runs_out}
    end
  end

  @doc """
  Early retirement check: if retirement_age < 60, super is inaccessible.
  Checks whether current_savings covers living expenses from retirement_age to 60.
  Returns {:covered, nil} or {:shortfall, amount}.
  """
  def compute_early_phase(%RetirementPlan{retirement_age: retirement_age} = plan)
      when retirement_age < 60 do
    gap_years = 60 - retirement_age
    total_needed = Decimal.mult(plan.annual_spend_in_retirement, gap_years)

    if Decimal.compare(plan.current_savings, total_needed) in [:gt, :eq] do
      {:covered, nil}
    else
      shortfall = Decimal.sub(total_needed, plan.current_savings) |> Decimal.round(2)
      {:shortfall, shortfall}
    end
  end

  def compute_early_phase(_plan), do: {:covered, nil}

  # --- Private ---

  defp do_compute(%RetirementPlan{} = plan) do
    super_at_retirement = compute_accumulation(plan)
    {runway_years, runs_out_at_age} = compute_drawdown(super_at_retirement, plan)

    {pre60_gap_covered, pre60_shortfall} =
      case compute_early_phase(plan) do
        {:covered, _} -> {true, nil}
        {:shortfall, diff} -> {false, diff}
      end

    %RetirementResult{
      super_at_retirement: super_at_retirement,
      runway_years: runway_years,
      runs_out_at_age: runs_out_at_age,
      pre60_gap_covered: pre60_gap_covered,
      pre60_shortfall: pre60_shortfall
    }
  end

  defp to_float(%Decimal{} = d), do: Decimal.to_float(d)
  defp to_float(n) when is_integer(n), do: n * 1.0
  defp to_float(n) when is_float(n), do: n
end
