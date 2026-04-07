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
        <.input
          field={@form[:category_id]}
          type="select"
          label="Category"
          options={Enum.map(Inventory.list_categories(), &{&1.name, &1.id})}
        />
        <.input
          field={@form[:tag_ids]}
          type="select"
          label="Tags"
          multiple
          options={Enum.map(Inventory.list_tags(), &{&1.name, &1.id})}
        />
        <div class="space-y-6 pt-2">
          <p class="text-sm font-medium text-zinc-700 dark:text-zinc-300">Images (optional, max 3)</p>
          
          <div class="grid gap-6 sm:grid-cols-3">
            <%= for slot <- 1..3 do %>
              <div class="rounded-xl border border-zinc-200/80 bg-zinc-50/50 p-4 dark:border-zinc-700 dark:bg-zinc-900/40">
                <p class="mb-3 text-xs font-semibold uppercase tracking-wide text-zinc-500 dark:text-zinc-400">
                  Slot {slot}
                </p>
                
                <%= if ri = radio_image_at(radio_images_list(@radio), slot) do %>
                  <div class="mb-3 overflow-hidden rounded-lg border border-zinc-200 dark:border-zinc-600">
                    <img
                      src={radio_image_url(ri)}
                      alt=""
                      class="h-32 w-full object-cover"
                    />
                  </div>
                  
                  <.button
                    type="button"
                    class="mb-3 w-full border border-zinc-300 bg-white text-zinc-800 hover:bg-zinc-50 dark:border-zinc-600 dark:bg-zinc-800 dark:text-zinc-100 dark:hover:bg-zinc-700"
                    phx-click="remove_image"
                    phx-value-slot={slot}
                    id={"remove-image-slot-#{slot}"}
                  >
                    Remove image
                  </.button>
                <% end %>
                
                <label class="block text-xs text-zinc-600 dark:text-zinc-400">
                  <%= if slot == 1 do %>
                    <.live_file_input upload={@uploads.radio_slot_1} class="block w-full text-sm" />
                  <% end %>
                  
                  <%= if slot == 2 do %>
                    <.live_file_input upload={@uploads.radio_slot_2} class="block w-full text-sm" />
                  <% end %>
                  
                  <%= if slot == 3 do %>
                    <.live_file_input upload={@uploads.radio_slot_3} class="block w-full text-sm" />
                  <% end %>
                </label>
              </div>
            <% end %>
          </div>
          
          <p class="text-xs text-zinc-500 dark:text-zinc-400">
            JPG, PNG, GIF, or WebP. Up to 10 MB per image.
          </p>
        </div>
        
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
    socket =
      socket
      |> assign(:return_to, return_to(params["return_to"]))
      |> apply_action(socket.assigns.live_action, params)
      |> allow_uploads()

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

  defp allow_uploads(socket) do
    opts = [accept: ~w(.jpg .jpeg .png .gif .webp), max_entries: 1, max_file_size: 10_000_000]

    socket
    |> allow_upload(:radio_slot_1, opts)
    |> allow_upload(:radio_slot_2, opts)
    |> allow_upload(:radio_slot_3, opts)
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
        case consume_all_slot_uploads(socket, radio) do
          {:ok, radio} ->
            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:info, "Radio updated successfully")
             |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

          {:error, reason} ->
            radio = Inventory.get_radio!(radio.id)
            msg = upload_error_message(reason)

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
        case consume_all_slot_uploads(socket, radio) do
          {:ok, radio} ->
            {:noreply,
             socket
             |> assign(:radio, radio)
             |> put_flash(:info, "Radio created successfully")
             |> push_navigate(to: return_path(socket.assigns.return_to, radio))}

          {:error, reason} ->
            radio = Inventory.get_radio!(radio.id)
            msg = upload_error_message(reason)

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

  defp consume_all_slot_uploads(socket, %Radio{id: id} = radio) when is_integer(id) do
    result =
      Enum.reduce_while(1..3, {:ok, radio}, fn slot, {:ok, radio} ->
        upload_atom = slot_upload_atom(slot)

        consume_uploaded_entries(socket, upload_atom, fn %{path: path}, entry ->
          # LiveView deletes the temp file after this callback; Waffle stores later in the Repo transaction.
          case File.read(path) do
            {:ok, binary} ->
              {:ok, %{filename: upload_filename_for_waffle(entry), binary: binary}}

            {:error, reason} ->
              {:error, "could not read upload: #{inspect(reason)}"}
          end
        end)
        |> case do
          [] ->
            {:cont, {:ok, radio}}

          [{:error, reason}] ->
            {:halt, {:error, {:read, reason}}}

          [upload] when is_map(upload) and is_map_key(upload, :binary) ->
            case Inventory.put_radio_image(radio, slot, upload) do
              {:ok, r} -> {:cont, {:ok, r}}
              {:error, cs} -> {:halt, {:error, {:upload, cs}}}
            end

          _ ->
            {:halt, {:error, :upload}}
        end
      end)

    case result do
      {:ok, radio} -> {:ok, radio}
      {:error, _} = e -> e
    end
  end

  defp slot_upload_atom(1), do: :radio_slot_1
  defp slot_upload_atom(2), do: :radio_slot_2
  defp slot_upload_atom(3), do: :radio_slot_3

  defp radio_images_list(%Radio{radio_images: %Ecto.Association.NotLoaded{}}), do: []

  defp radio_images_list(%Radio{radio_images: list}) when is_list(list), do: list

  defp radio_images_list(%Radio{}), do: []

  defp radio_image_at(images, slot) when is_list(images) do
    Enum.find(images, &(&1.slot == slot))
  end

  defp radio_image_url(%Myappv1.Inventory.RadioImage{} = ri) do
    Myappv1.Uploaders.RadioImage.url({ri.image, ri}, :original)
  end

  defp upload_filename_for_waffle(entry) do
    base = entry.client_name |> Kernel.||("upload") |> Path.basename()
    ext = Path.extname(base) |> String.downcase()

    if ext != "" do
      base
    else
      base <> ext_from_mime(entry.client_type)
    end
  end

  defp ext_from_mime("image/jpeg"), do: ".jpg"
  defp ext_from_mime("image/jpg"), do: ".jpg"
  defp ext_from_mime("image/png"), do: ".png"
  defp ext_from_mime("image/gif"), do: ".gif"
  defp ext_from_mime("image/webp"), do: ".webp"
  defp ext_from_mime(_), do: ".jpg"

  defp upload_error_message({:upload, %Ecto.Changeset{} = cs}) do
    detail =
      cs
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map_join("; ", fn {k, v} -> "#{k}: #{Enum.join(v, ", ")}" end)

    if detail != "" do
      "Radio tersimpan, tetapi gambar gagal: #{detail}"
    else
      "Radio tersimpan, tetapi gambar gagal disimpan."
    end
  end

  defp upload_error_message({:read, reason}) do
    "Radio tersimpan, tetapi berkas upload tidak bisa dibaca (#{inspect(reason)})."
  end

  defp upload_error_message(_),
    do: "Radio tersimpan, tetapi satu atau lebih gambar gagal disimpan."

  defp return_path("index", _radio), do: ~p"/radios"
  defp return_path("show", %Radio{id: id}) when is_integer(id), do: ~p"/radios/#{id}"
  defp return_path("show", _), do: ~p"/radios"
end
