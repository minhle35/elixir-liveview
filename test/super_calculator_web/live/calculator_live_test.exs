defmodule SuperCalculatorWeb.CalculatorLiveTest do
  use SuperCalculatorWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "renders the calculator page", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")
    assert has_element?(view, "#salary-input")
    assert has_element?(view, "#calculations")
  end

  test "shows super contribution when salary is entered", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#calculator-form")
    |> render_change(%{"salary" => "100000"})

    assert has_element?(view, "#save-btn")
    assert render(view) =~ "11500"
  end

  test "shows error for invalid salary", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#calculator-form")
    |> render_change(%{"salary" => "abc"})

    assert render(view) =~ "Please enter a valid salary"
  end

  test "saves a calculation and shows it in the list", %{conn: conn} do
    {:ok, view, _html} = live(conn, "/")

    view
    |> element("#calculator-form")
    |> render_change(%{"salary" => "80000"})

    view
    |> element("#calculator-form")
    |> render_submit(%{"salary" => "80000"})

    assert render(view) =~ "80000"
    assert render(view) =~ "9200"
  end
end
