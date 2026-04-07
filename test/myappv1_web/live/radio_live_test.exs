defmodule Myappv1Web.RadioLiveTest do
  use Myappv1Web.ConnCase

  import Phoenix.LiveViewTest
  import Myappv1.InventoryFixtures

  alias Myappv1.Inventory

  @create_attrs %{code: "some code", name: "some name"}
  @update_attrs %{code: "some updated code", name: "some updated name"}
  @invalid_attrs %{code: nil, name: nil}
  defp create_radio(_) do
    radio = radio_fixture()

    %{radio: radio}
  end

  describe "Index" do
    setup [:create_radio]

    test "lists all radios", %{conn: conn, radio: radio} do
      {:ok, _index_live, html} = live(conn, ~p"/radios")

      assert html =~ "Listing Radios"
      assert html =~ radio.name
    end

    test "saves new radio", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Radio")
               |> render_click()
               |> follow_redirect(conn, ~p"/radios/new")

      assert render(form_live) =~ "New Radio"

      assert form_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#radio-form", radio: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/radios")

      html = render(index_live)
      assert html =~ "Radio created successfully"
      assert html =~ "some name"
    end

    test "updates radio in listing", %{conn: conn, radio: radio} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#radios-#{radio.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/radios/#{radio}/edit")

      assert render(form_live) =~ "Edit Radio"

      assert form_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#radio-form", radio: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/radios")

      html = render(index_live)
      assert html =~ "Radio updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes radio in listing", %{conn: conn, radio: radio} do
      {:ok, index_live, _html} = live(conn, ~p"/radios")

      assert index_live |> element("#radios-#{radio.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#radios-#{radio.id}")
    end
  end

  describe "Show (controller)" do
    setup [:create_radio]

    test "displays radio", %{conn: conn, radio: radio} do
      conn = get(conn, ~p"/radios/#{radio}")
      html = html_response(conn, 200)
      assert html =~ "Radio #{radio.id}"
      assert html =~ radio.name
    end

    test "updates radio from edit with return_to show", %{conn: conn, radio: radio} do
      {:ok, form_live, _html} = live(conn, ~p"/radios/#{radio}/edit?return_to=show")

      assert render(form_live) =~ "Edit Radio"

      assert form_live
             |> form("#radio-form", radio: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      form_live
      |> form("#radio-form", radio: @update_attrs)
      |> render_submit()

      assert Inventory.get_radio!(radio.id).name == "some updated name"

      conn = get(conn, ~p"/radios/#{radio}")
      assert html_response(conn, 200) =~ "some updated name"
    end
  end
end
