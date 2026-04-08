defmodule Myappv1Web.RadioLive.Form do
  use Myappv1Web, :live_view

  alias Myappv1.Inventory
  alias Myappv1.Inventory.Radio
  alias Myappv1Web.RadioLive.FormComponents
  alias Myappv1Web.RadioLive.UploadHelpers

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage radio records in your database.</:subtitle>
      </.header>

      <FormComponents.radio_form
        form={@form}
        radio={@radio}
        uploads={@uploads}
        category_options={@category_options}
        tag_options={@tag_options}
        cancel_path={return_path(@return_to, @radio)}
      />
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket =
      socket
      |> assign(:return_to, return_to(params["return_to"]))
      |> assign_select_options()
      |> apply_action(socket.assigns.live_action, params)
      |> UploadHelpers.allow_uploads()

    {:ok, socket}
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

  defp assign_select_options(socket) do
    socket
    |> assign(:category_options, Enum.map(Inventory.list_categories(), &{&1.name, &1.id}))
    |> assign(:tag_options, Enum.map(Inventory.list_tags(), &{&1.name, &1.id}))
  end

  @impl true
  def handle_event("validate", %{"radio" => radio_params}, socket) do
    changeset = Inventory.change_radio(socket.assigns.radio, radio_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"radio" => radio_params}, socket) do
    save_radio(socket, socket.assigns.live_action, radio_params)
  end

  def handle_event("remove_image", %{"slot" => slot}, socket) do
    slot = String.to_integer(slot)

    case socket.assigns.radio do
      %Radio{id: nil} ->
        {:noreply, socket}

      %Radio{} = radio ->
        case Inventory.delete_radio_image_slot(radio, slot) do
          {:ok, _} ->
            radio = Inventory.get_radio!(radio.id)
            {:noreply, assign(socket, :radio, radio)}

          {:error, _} ->
            {:noreply, put_flash(socket, :error, "Could not remove image")}
        end
    end
  end

  defp save_radio(socket, :edit, radio_params) do
    case Inventory.update_radio(socket.assigns.radio, radio_params) do
      {:ok, radio} ->
        # Upload diproses setelah update data inti agar perubahan form tetap tersimpan walau upload gagal.
        case UploadHelpers.consume_all_slot_uploads(socket, radio) do
          {:ok, radio} ->
            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:info, "Radio updated successfully")
             |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

          {:error, reason} ->
            radio = Inventory.get_radio!(radio.id)
            msg = UploadHelpers.upload_error_message(reason)

            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:error, msg)}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_radio(socket, :new, radio_params) do
    case Inventory.create_radio(radio_params) do
      {:ok, radio} ->
        # Pola sama dengan edit: simpan radio dulu, lalu proses upload tiap slot.
        case UploadHelpers.consume_all_slot_uploads(socket, radio) do
          {:ok, radio} ->
            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:info, "Radio created successfully")
             |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

          {:error, reason} ->
            radio = Inventory.get_radio!(radio.id)
            msg = UploadHelpers.upload_error_message(reason)

            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:error, msg)
             |> push_navigate(to: ~p"/radios/#{radio}/edit")}
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path("index", _radio), do: ~p"/radios"
  defp return_path("show", %Radio{id: id}) when is_integer(id), do: ~p"/radios/#{id}"
  defp return_path("show", _), do: ~p"/radios"
end
