defmodule Myappv1Web.RadioLive.Form do
  use Myappv1Web, :live_view

  alias Myappv1.Inventory
  alias Myappv1.Inventory.Radio

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage radio records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="radio-form" phx-change="validate" phx-submit="save">
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:code]} type="text" label="Code" />
        <.input field={@form[:category_id]} type="select" label="Category" options={Enum.map(Inventory.list_categories(), &{&1.name, &1.id})} />
        <.input field={@form[:tag_ids]} type="select" label="Tags" multiple options={Enum.map(Inventory.list_tags(), &{&1.name, &1.id})} />

        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Radio</.button>
          <.button navigate={return_path(@return_to, @radio)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    radio = Inventory.get_radio!(id)

    socket
    |> assign(:page_title, "Edit Radio")
    |> assign(:radio, radio)
    |> assign(:form, to_form(Inventory.change_radio(radio)))
  end

  defp apply_action(socket, :new, _params) do
    radio = %Radio{}

    socket
    |> assign(:page_title, "New Radio")
    |> assign(:radio, radio)
    |> assign(:form, to_form(Inventory.change_radio(radio)))
  end

  @impl true
  def handle_event("validate", %{"radio" => radio_params}, socket) do
    changeset = Inventory.change_radio(socket.assigns.radio, radio_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"radio" => radio_params}, socket) do
    save_radio(socket, socket.assigns.live_action, radio_params)
  end

  defp save_radio(socket, :edit, radio_params) do
    case Inventory.update_radio(socket.assigns.radio, radio_params) do
      {:ok, radio} ->
        {:noreply,
         socket
         |> put_flash(:info, "Radio updated successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_radio(socket, :new, radio_params) do
    case Inventory.create_radio(radio_params) do
      {:ok, radio} ->
        {:noreply,
         socket
         |> put_flash(:info, "Radio created successfully")
         |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _radio), do: ~p"/radios"
  defp return_path("show", radio), do: ~p"/radios/#{radio}"
end
