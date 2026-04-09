defmodule SuperCalculatorWeb.RetirementLive do
  use SuperCalculatorWeb, :live_view

  alias SuperCalculator.{Retirement, RetirementPlan}

  @defaults %{
    "super_rate" => "11.5",
    "investment_return_rate" => "7.0",
    "life_expectancy" => "85",
    "current_super_balance" => "0",
    "current_savings" => "0"
  }

  @impl true
  def mount(_params, _session, socket) do
    changeset = RetirementPlan.changeset(%RetirementPlan{}, @defaults)

    {:ok,
     socket
     |> assign(:changeset, changeset)
     |> assign(:result, nil)}
  end

  @impl true
  def handle_event("validate", %{"retirement_plan" => params}, socket) do
    merged = Map.merge(@defaults, params)
    changeset = RetirementPlan.changeset(%RetirementPlan{}, merged) |> Map.put(:action, :validate)

    result =
      case Retirement.compute_all(merged) do
        {:ok, r} -> r
        {:error, _} -> nil
      end

    {:noreply,
     socket
     |> assign(:changeset, changeset)
     |> assign(:result, result)}
  end

  defp early_retirement?(changeset) do
    case Ecto.Changeset.get_field(changeset, :retirement_age) do
      nil -> false
      age -> age < 60
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <div>
          <h1 class="text-3xl font-bold tracking-tight">Retirement Planner</h1>
          <p class="mt-1 text-base-content/60">
            Will your super last through retirement?
          </p>
        </div>

        <.form
          for={@changeset}
          id="retirement-form"
          phx-change="validate"
          class="space-y-6"
          :let={f}
        >
          <%!-- PHASE 1: Accumulation --%>
          <div class="card bg-base-200 p-6 space-y-4">
            <h2 class="text-xl font-semibold">Phase 1 — Accumulation</h2>
            <p class="text-sm text-base-content/60">How much super will you have by retirement?</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium mb-1">Current Age</label>
                <.input field={f[:current_age]} type="number" min="1" max="99" placeholder="e.g. 30" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Retirement Age</label>
                <.input field={f[:retirement_age]} type="number" min="1" max="99" placeholder="e.g. 65" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Annual Salary ($)</label>
                <.input field={f[:current_salary]} type="number" min="0" placeholder="e.g. 100000" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Super Rate (%)</label>
                <.input field={f[:super_rate]} type="number" min="0" max="100" step="0.1" placeholder="11.5" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Current Super Balance ($)</label>
                <.input field={f[:current_super_balance]} type="number" min="0" placeholder="e.g. 50000" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Investment Return Rate (%)</label>
                <.input field={f[:investment_return_rate]} type="number" min="0" step="0.1" placeholder="7.0" />
              </div>
            </div>

            <%= if early_retirement?(@changeset) do %>
              <div class="alert alert-warning mt-2">
                <span class="font-semibold">Early retirement detected.</span>
                Super is inaccessible before age 60 in Australia.
                Enter your personal savings to cover living expenses until then.
              </div>
              <div>
                <label class="block text-sm font-medium mb-1">Personal Savings ($)</label>
                <.input field={f[:current_savings]} type="number" min="0" placeholder="e.g. 200000" />
              </div>
            <% end %>
          </div>

          <%!-- PHASE 2: Drawdown --%>
          <div class="card bg-base-200 p-6 space-y-4">
            <h2 class="text-xl font-semibold">Phase 2 — Drawdown</h2>
            <p class="text-sm text-base-content/60">How long will your super last?</p>

            <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <label class="block text-sm font-medium mb-1">Annual Spend in Retirement ($)</label>
                <.input field={f[:annual_spend_in_retirement]} type="number" min="0" placeholder="e.g. 60000" />
              </div>

              <div>
                <label class="block text-sm font-medium mb-1">Life Expectancy</label>
                <.input field={f[:life_expectancy]} type="number" min="1" max="129" placeholder="85" />
              </div>
            </div>
          </div>

          <%!-- RESULTS --%>
          <%= if @result do %>
            <div class="card bg-base-100 border border-base-300 p-6 space-y-4">
              <h2 class="text-xl font-semibold">Results</h2>

              <div class="flex justify-between items-center py-2 border-b border-base-200">
                <span class="text-base-content/60">Super at retirement</span>
                <span class="text-2xl font-bold text-primary">
                  $<%= Decimal.round(@result.super_at_retirement, 0) %>
                </span>
              </div>

              <%= if @result.pre60_gap_covered == false do %>
                <div class="alert alert-error">
                  <div>
                    <p class="font-semibold">Savings gap before age 60</p>
                    <p class="text-sm">
                      Your savings won't cover living expenses until super is accessible.
                      Shortfall: <strong>$<%= Decimal.round(@result.pre60_shortfall, 0) %></strong>
                    </p>
                  </div>
                </div>
              <% end %>

              <%= if @result.runs_out_at_age do %>
                <div class="alert alert-error">
                  <div>
                    <p class="font-semibold">Super runs out at age <%= @result.runs_out_at_age %></p>
                    <p class="text-sm">
                      That's <%= Decimal.round(@result.runway_years, 1) %> years of retirement income.
                      Consider increasing contributions or reducing expenses.
                    </p>
                  </div>
                </div>
              <% else %>
                <div class="alert alert-success">
                  <p class="font-semibold">
                    Your super will outlast your life expectancy of <%= Ecto.Changeset.get_field(@changeset, :life_expectancy) %>.
                  </p>
                </div>
              <% end %>

              <button type="submit" class="btn btn-primary w-full">Save Retirement Plan</button>
            </div>
          <% end %>
        </.form>
      </div>
    </Layouts.app>
    """
  end
end
