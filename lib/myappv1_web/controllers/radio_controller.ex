defmodule Myappv1Web.RadioController do
  use Myappv1Web, :controller

  alias Myappv1.Inventory
  alias Myappv1.Inventory.Radio

  def index(conn, _params) do
    radios = Inventory.list_radios()
    render(conn, :index, radios: radios)
  end

  def new(conn, _params) do
    changeset = Inventory.change_radio(%Radio{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"radio" => radio_params}) do
    case Inventory.create_radio(radio_params) do
      {:ok, radio} ->
        conn
        |> put_flash(:info, "Radio created successfully.")
        |> redirect(to: ~p"/radios/#{radio}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    radio = Inventory.get_radio!(id)
    render(conn, :show, radio: radio)
  end

  def edit(conn, %{"id" => id}) do
    radio = Inventory.get_radio!(id)
    changeset = Inventory.change_radio(radio)
    render(conn, :edit, radio: radio, changeset: changeset)
  end

  def update(conn, %{"id" => id, "radio" => radio_params}) do
    radio = Inventory.get_radio!(id)

    case Inventory.update_radio(radio, radio_params) do
      {:ok, radio} ->
        conn
        |> put_flash(:info, "Radio updated successfully.")
        |> redirect(to: ~p"/radios/#{radio}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, radio: radio, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    radio = Inventory.get_radio!(id)
    {:ok, _radio} = Inventory.delete_radio(radio)

    conn
    |> put_flash(:info, "Radio deleted successfully.")
    |> redirect(to: ~p"/radios")
  end
end
