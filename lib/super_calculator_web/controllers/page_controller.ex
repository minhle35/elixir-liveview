defmodule SuperCalculatorWeb.PageController do
  use SuperCalculatorWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
