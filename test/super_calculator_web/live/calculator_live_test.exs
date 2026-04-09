defmodule SuperCalculatorWeb.CalculatorLiveTest do
  use SuperCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the retirement planner page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert has_element?(view, "#retirement-form")
    assert render(view) =~ "Retirement Planner"
  end

  test "shows results when all required inputs are provided", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#retirement-form")
    |> render_change(%{
      "retirement_plan" => %{
        "current_age" => "30",
        "retirement_age" => "65",
        "current_salary" => "100000",
        "super_rate" => "11.5",
        "current_super_balance" => "10000",
        "investment_return_rate" => "7.0",
        "annual_spend_in_retirement" => "60000",
        "life_expectancy" => "85",
        "current_savings" => "0"
      }
    })

    assert render(view) =~ "Super at retirement"
  end

  test "shows early retirement warning when retirement age is under 60", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#retirement-form")
    |> render_change(%{
      "retirement_plan" => %{
        "current_age" => "30",
        "retirement_age" => "55",
        "current_salary" => "100000",
        "super_rate" => "11.5",
        "current_super_balance" => "0",
        "investment_return_rate" => "7.0",
        "annual_spend_in_retirement" => "60000",
        "life_expectancy" => "85",
        "current_savings" => "0"
      }
    })

    assert render(view) =~ "Early retirement detected"
  end

  test "shows inline error when retirement age is less than current age", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#retirement-form")
    |> render_change(%{
      "retirement_plan" => %{
        "current_age" => "65",
        "retirement_age" => "30",
        "current_salary" => "100000",
        "super_rate" => "11.5",
        "current_super_balance" => "0",
        "investment_return_rate" => "7.0",
        "annual_spend_in_retirement" => "60000",
        "life_expectancy" => "85",
        "current_savings" => "0"
      }
    })

    assert render(view) =~ "must be greater than current age"
  end
end
