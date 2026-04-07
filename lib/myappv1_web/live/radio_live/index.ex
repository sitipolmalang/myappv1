defmodule Myappv1Web.RadioLive.Index do
  use Myappv1Web, :live_view

  alias Myappv1.Inventory
  alias Myappv1.Inventory.Radio

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
        <:col :let={{_id, radio}} label="Image">
          <%= if src = first_radio_image_url(radio) do %>
            <img
              src={src}
              alt=""
              class="h-10 w-10 rounded-md object-cover ring-1 ring-zinc-200 dark:ring-zinc-600"
            />
          <% else %>
            <span class="text-zinc-400">—</span>
          <% end %>
        </:col>
        
        <:col :let={{_id, radio}} label="Name">{radio.name}</:col>
        
        <:col :let={{_id, radio}} label="Code">{radio.code}</:col>
        
        <:col :let={{_id, radio}} label="Category">
          <%= if radio.category do %>
            {radio.category.name}
          <% else %>
            No Category
          <% end %>
        </:col>
        
        <:col :let={{_id, radio}} label="Tags">
          <%= if radio.tags && length(radio.tags) > 0 do %>
            {Enum.map_join(radio.tags, ", ", & &1.name)}
          <% else %>
            No Tags
          <% end %>
        </:col>
        
        <:action :let={{_id, radio}}>
          <div class="sr-only"><.link navigate={~p"/radios/#{radio}"}>Show</.link></div>
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

  defp first_radio_image_url(%Radio{radio_images: []}), do: nil

  defp first_radio_image_url(%Radio{radio_images: list}) when is_list(list) do
    list
    |> Enum.sort_by(& &1.slot)
    |> List.first()
    |> case do
      nil -> nil
      ri -> Myappv1.Uploaders.RadioImage.url({ri.image, ri}, :original)
    end
  end

  defp first_radio_image_url(_), do: nil
end
