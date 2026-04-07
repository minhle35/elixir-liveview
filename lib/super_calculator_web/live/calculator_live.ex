defmodule SuperCalculatorWeb.CalculatorLive do
  use SuperCalculatorWeb, :live_view

  alias SuperCalculator.Calculations

  @impl true
  def mount(_params, _session, socket) do
    calculations = Calculations.list_calculations()

    socket =
      socket
      |> assign(:salary, "")
      |> assign(:super_contribution, nil)
      |> assign(:error, nil)
      |> stream(:calculations, calculations)

    {:ok, socket}
  end

  @impl true
  def handle_event("calculate", %{"salary" => salary}, socket) do
    case Calculations.compute_super(salary) do
      {:ok, super_contribution} ->
        {:noreply,
         socket
         |> assign(:salary, salary)
         |> assign(:super_contribution, super_contribution)
         |> assign(:error, nil)}

      {:error, :invalid} ->
        {:noreply,
         socket
         |> assign(:salary, salary)
         |> assign(:super_contribution, nil)
         |> assign(:error, "Please enter a valid salary")}
    end
  end

  def handle_event("save", %{"salary" => salary}, socket) do
    case Calculations.save_calculation(salary) do
      {:ok, calculation} ->
        {:noreply,
         socket
         |> stream_insert(:calculations, calculation, at: 0)
         |> put_flash(:info, "Saved!")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Could not save calculation")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class="space-y-8">
        <div>
          <h1 class="text-3xl font-bold tracking-tight">Super Calculator</h1>
          <p class="mt-1 text-base-content/60">Calculate your 11.5% superannuation contribution</p>
        </div>

        <div class="card bg-base-200 p-6 space-y-4">
          <div>
            <label for="salary-input" class="block text-sm font-medium mb-1">Annual Salary ($)</label>
            <input
              id="salary-input"
              type="number"
              min="0"
              step="1"
              placeholder="e.g. 80000"
              value={@salary}
              phx-keyup="calculate"
              phx-key="Enter"
              phx-change="calculate"
              name="salary"
              class="input input-bordered w-full"
            />
            <%= if @error do %>
              <p class="mt-1 text-sm text-error">{@error}</p>
            <% end %>
          </div>

          <%= if @super_contribution do %>
            <div class="bg-base-100 rounded-lg p-4 space-y-1">
              <p class="text-sm text-base-content/60">Super contribution (11.5%)</p>
              <p class="text-2xl font-bold text-success">
                ${Decimal.round(@super_contribution, 2)}
              </p>
            </div>
            <button
              id="save-btn"
              phx-click="save"
              phx-value-salary={@salary}
              class="btn btn-primary w-full"
            >
              Save Calculation
            </button>
          <% end %>
        </div>

        <div>
          <h2 class="text-lg font-semibold mb-3">Recent Calculations</h2>
          <div id="calculations" phx-update="stream" class="space-y-2">
            <div id="empty-state" class="hidden only:block text-base-content/50 text-sm">No calculations saved yet.</div>
            <div
              :for={{id, calc} <- @streams.calculations}
              id={id}
              class="card bg-base-200 px-4 py-3 flex flex-row justify-between items-center"
            >
              <span class="text-sm text-base-content/60">Salary: <span class="font-medium text-base-content">${Decimal.round(calc.salary, 2)}</span></span>
              <span class="text-sm">Super: <span class="font-semibold text-success">${Decimal.round(calc.super_contribution, 2)}</span></span>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end
end
