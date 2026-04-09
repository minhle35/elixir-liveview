defmodule SuperCalculatorWeb.PageControllerTest do
  use SuperCalculatorWeb.ConnCase

  import Phoenix.LiveViewTest

  test "GET / redirects to LiveView", %{conn: conn} do
    {:ok, _view, html} = live(conn, "/")
    assert html =~ "Retirement Planner"
  end
end
