defmodule Myappv1Web.PageController do
  use Myappv1Web, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
