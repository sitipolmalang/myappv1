defmodule Myappv1Web.RadioLive.UploadHelpers do
  alias Myappv1.Inventory
  alias Myappv1.Inventory.Radio

  def allow_uploads(socket) do
    opts = [accept: ~w(.jpg .jpeg .png .gif .webp), max_entries: 1, max_file_size: 2_000_000]

    socket
    |> Phoenix.LiveView.allow_upload(:radio_slot_1, opts)
    |> Phoenix.LiveView.allow_upload(:radio_slot_2, opts)
    |> Phoenix.LiveView.allow_upload(:radio_slot_3, opts)
  end

  def consume_all_slot_uploads(socket, %Radio{id: id} = radio) when is_integer(id) do
    Enum.reduce_while(1..3, {:ok, radio}, fn slot, {:ok, current_radio} ->
      upload_atom = slot_upload_atom(slot)

      Phoenix.LiveView.consume_uploaded_entries(socket, upload_atom, fn %{path: path}, entry ->
        # Optimized file reading: stream large files to avoid memory spikes
        case File.stat(path) do
          # Stream files > 500KB
          {:ok, %{size: size}} when size > 500_000 ->
            try do
              # 64KB chunks for better performance
              stream = File.stream!(path, [], 65536)
              binary = Enum.reduce(stream, <<>>, &(&2 <> &1))
              {:ok, %{filename: upload_filename_for_waffle(entry), binary: binary}}
            rescue
              e -> {:error, "could not stream upload: #{inspect(e)}"}
            end

          # Read smaller files directly
          {:ok, _} ->
            case File.read(path) do
              {:ok, binary} ->
                {:ok, %{filename: upload_filename_for_waffle(entry), binary: binary}}

              {:error, reason} ->
                {:error, "could not read upload: #{inspect(reason)}"}
            end

          {:error, reason} ->
            {:error, "could not access upload file: #{inspect(reason)}"}
        end
      end)
      |> case do
        [] ->
          {:cont, {:ok, current_radio}}

        [{:error, reason}] ->
          {:halt, {:error, {:read, reason}}}

        [upload] when is_map(upload) and is_map_key(upload, :binary) ->
          case Inventory.put_radio_image(current_radio, slot, upload) do
            {:ok, updated_radio} -> {:cont, {:ok, updated_radio}}
            {:error, changeset} -> {:halt, {:error, {:upload, changeset}}}
          end

        _ ->
          {:halt, {:error, :upload}}
      end
    end)
  end

  def radio_images_list(%Radio{radio_images: %Ecto.Association.NotLoaded{}}), do: []
  def radio_images_list(%Radio{radio_images: list}) when is_list(list), do: list
  def radio_images_list(%Radio{}), do: []

  def radio_image_at(images, slot) when is_list(images) do
    Enum.find(images, &(&1.slot == slot))
  end

  def radio_image_url(%Myappv1.Inventory.RadioImage{} = ri) do
    Myappv1.Uploaders.RadioImage.url({ri.image, ri}, :original)
  end

  def upload_error_message({:upload, %Ecto.Changeset{} = changeset}) do
    detail =
      changeset
      |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map_join("; ", fn {key, value} -> "#{key}: #{Enum.join(value, ", ")}" end)

    if detail != "" do
      "Gambar gagal: #{detail}"
    else
      "Gambar gagal disimpan."
    end
  end

  def upload_error_message({:read, reason}) do
    "Berkas upload tidak bisa dibaca (#{inspect(reason)})."
  end

  def upload_error_message(:upload),
    do: "Satu atau lebih gambar gagal disimpan."

  defp slot_upload_atom(1), do: :radio_slot_1
  defp slot_upload_atom(2), do: :radio_slot_2
  defp slot_upload_atom(3), do: :radio_slot_3

  defp upload_filename_for_waffle(entry) do
    base = entry.client_name |> Kernel.||("upload") |> Path.basename()
    ext = Path.extname(base) |> String.downcase()

    if ext != "" do
      base
    else
      # Fallback ekstensi diperlukan agar uploader punya nama file valid.
      base <> ext_from_mime(entry.client_type)
    end
  end

  defp ext_from_mime("image/jpeg"), do: ".jpg"
  defp ext_from_mime("image/jpg"), do: ".jpg"
  defp ext_from_mime("image/png"), do: ".png"
  defp ext_from_mime("image/gif"), do: ".gif"
  defp ext_from_mime("image/webp"), do: ".webp"
  defp ext_from_mime(_), do: ".jpg"
end
