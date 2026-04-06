defmodule Myappv1Web.RadioControllerTest do
  use Myappv1Web.ConnCase

  import Myappv1.InventoryFixtures

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}

  describe "index" do
    test "lists all radios", %{conn: conn} do
      conn = get(conn, ~p"/radios")
      assert html_response(conn, 200) =~ "Listing Radios"
    end
  end

  describe "new radio" do
    test "renders form", %{conn: conn} do
      conn = get(conn, ~p"/radios/new")
      assert html_response(conn, 200) =~ "New Radio"
    end
  end

  describe "create radio" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/radios", radio: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/radios/#{id}"

      conn = get(conn, ~p"/radios/#{id}")
      assert html_response(conn, 200) =~ "Radio #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/radios", radio: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Radio"
    end
  end

  describe "edit radio" do
    setup [:create_radio]

    test "renders form for editing chosen radio", %{conn: conn, radio: radio} do
      conn = get(conn, ~p"/radios/#{radio}/edit")
      assert html_response(conn, 200) =~ "Edit Radio"
    end
  end

  describe "update radio" do
    setup [:create_radio]

    test "redirects when data is valid", %{conn: conn, radio: radio} do
      conn = put(conn, ~p"/radios/#{radio}", radio: @update_attrs)
      assert redirected_to(conn) == ~p"/radios/#{radio}"

      conn = get(conn, ~p"/radios/#{radio}")
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, radio: radio} do
      conn = put(conn, ~p"/radios/#{radio}", radio: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Radio"
    end
  end

  describe "delete radio" do
    setup [:create_radio]

    test "deletes chosen radio", %{conn: conn, radio: radio} do
      conn = delete(conn, ~p"/radios/#{radio}")
      assert redirected_to(conn) == ~p"/radios"

      assert_error_sent 404, fn ->
        get(conn, ~p"/radios/#{radio}")
      end
    end
  end

  defp create_radio(_) do
    radio = radio_fixture()

    %{radio: radio}
  end
end
