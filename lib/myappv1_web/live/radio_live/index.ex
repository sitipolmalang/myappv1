defmodule Myappv1Web.RadioLive.Index do
  use Myappv1Web, :live_view

  alias Myappv1.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Listing Radios
        <:actions>
          <.button variant="primary" navigate={~p"/radios/new"}>
            <.icon name="hero-plus" /> New Radio
          </.button>
        </:actions>
      </.header>

      <.table
        id="radios"
        rows={@streams.radios}
        row_click={fn {_id, radio} -> JS.navigate(~p"/radios/#{radio}") end}
      >
        <:col :let={{_id, radio}} label="Name">{radio.name}</:col>
        <:col :let={{_id, radio}} label="Code">{radio.code}</:col>
        <:col :let={{_id, radio}} label="Category">
          <%= if radio.category do %>
            <%= radio.category.name %>
          <% else %>
            No Category
          <% end %>
        </:col>
        <:col :let={{_id, radio}} label="Tags">
          <%= if radio.tags && length(radio.tags) > 0 do %>
            <%= Enum.map_join(radio.tags, ", ", & &1.name) %>
          <% else %>
            No Tags
          <% end %>
        </:col>
        <:action :let={{_id, radio}}>
          <div class="sr-only">
            <.link navigate={~p"/radios/#{radio}"}>Show</.link>
          </div>
          <.link navigate={~p"/radios/#{radio}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, radio}}>
          <.link
            phx-click={JS.push("delete", value: %{id: radio.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Listing Radios")
     |> stream(:radios, list_radios())}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    radio = Inventory.get_radio!(id)
    {:ok, _} = Inventory.delete_radio(radio)

    {:noreply, stream_delete(socket, :radios, radio)}
  end

  defp list_radios() do
    Inventory.list_radios()
  end
end
