defmodule Myappv1Web.RadioLive.Show do
  use Myappv1Web, :live_view

  alias Myappv1.Inventory

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        Radio {@radio.id}
        <:subtitle>This is a radio record from your database.</:subtitle>
        
        <:actions>
          <.button navigate={~p"/radios"}><.icon name="hero-arrow-left" /></.button>
          <.button variant="primary" navigate={~p"/radios/#{@radio}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit radio
          </.button>
        </:actions>
      </.header>
      
      <.list>
        <:item title="Name">{@radio.name}</:item>
        
        <:item title="Code">{@radio.code}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Radio")
     |> assign(:radio, Inventory.get_radio!(id))}
  end
end
