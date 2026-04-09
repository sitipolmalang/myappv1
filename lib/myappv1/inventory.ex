defmodule Myappv1.Inventory do
  @moduledoc """
  Modul Inventory berfungsi sebagai konteks/data layer untuk mengelola data radio, kategori, dan tag.
  Module ini menyediakan fungsi-fungsi untuk operasi CRUD (Create, Read, Update, Delete)
  terhadap entitas-entitas tersebut menggunakan Ecto dan Repo.
  """

  import Ecto.Query, warn: false
  import Ecto.Changeset, only: [put_assoc: 3]
  alias Myappv1.Repo

  alias Myappv1.Inventory.Radio
  alias Myappv1.Inventory.RadioImage
  alias Myappv1.Inventory.Category
  alias Myappv1.Inventory.Tag

  # ============ FUNGSI CRUD UNTUK RADIO ============

  @doc """
  Mengambil semua data radio dari database.
  Seluruh data radio akan dimuat beserta relasi category dan tags-nya.
  """
  def list_radios do
    Repo.all(Radio)
    |> Repo.preload([
      :category,
      :tags,
      radio_images: from(ri in RadioImage, order_by: [asc: ri.slot])
    ])
  end

  @doc """
  Mengambil satu data radio berdasarkan ID.
  Jika radio tidak ditemukan, akan melempar exception Ecto.NoResultsError.
  """
  def get_radio!(id) do
    Repo.get!(Radio, id)
    |> Repo.preload([
      :category,
      :tags,
      radio_images: from(ri in RadioImage, order_by: [asc: ri.slot])
    ])
  end

  @doc """
  Membuat data radio baru dengan atribut yang diberikan.
  Contoh attrs: %{name: "Radio Kita", category_id: 1, tag_ids: [1, 2, 3]}
  """
  def create_radio(attrs) do
    %Radio{}
    |> Radio.changeset(attrs)
    |> put_assoc(:tags, tags_for_attrs(attrs))
    |> Repo.insert()
  end

  @doc """
  Memperbarui data radio yang sudah ada.
  Perlu melakukan preload tags terlebih dahulu agar relasi dapat diperbarui dengan benar.
  """
  def update_radio(%Radio{} = radio, attrs) do
    radio
    |> Repo.preload(:tags)
    |> Radio.changeset(attrs)
    |> put_assoc(:tags, tags_for_attrs(attrs))
    |> Repo.update()
    |> case do
      {:ok, radio} ->
        {:ok,
         Repo.preload(radio, [
           :category,
           :tags,
           radio_images: from(ri in RadioImage, order_by: [asc: ri.slot])
         ])}

      error ->
        error
    end
  end

  @doc """
  Menyimpan atau mengganti gambar pada slot 1..3 untuk sebuah radio.
  `upload` dapat berupa `%Plug.Upload{}` atau `%{filename: binary(), binary: binary()}` (mis. dari LiveView setelah `File.read`).
  """
  def put_radio_image(%Radio{} = radio, slot, upload) when slot in 1..3 do
    radio = Repo.preload(radio, :radio_images)
    existing = Enum.find(radio.radio_images, &(&1.slot == slot))

    # Hapus file lama di luar transaction untuk menghindari I/O blocking
    file_to_delete = if existing, do: existing, else: nil

    result =
      Repo.transaction(fn ->
        if existing do
          Repo.delete!(existing)
        end

        %RadioImage{}
        |> RadioImage.changeset(%{
          "radio_id" => radio.id,
          "slot" => slot,
          "image" => upload
        })
        |> Repo.insert()
        |> case do
          {:ok, ri} -> ri
          {:error, cs} -> Repo.rollback(cs)
        end
      end)

    # Hapus file lama setelah transaction berhasil
    if file_to_delete && match?({:ok, _}, result) do
      delete_radio_image_file(file_to_delete)
    end

    case result do
      {:ok, _} -> {:ok, get_radio!(radio.id)}
      {:error, %Ecto.Changeset{} = cs} -> {:error, cs}
      {:error, _} = other -> other
    end
  end

  @doc """
  Menghapus gambar pada slot tertentu (jika ada).
  """
  def delete_radio_image_slot(%Radio{} = radio, slot) when slot in 1..3 do
    case Repo.get_by(RadioImage, radio_id: radio.id, slot: slot) do
      nil ->
        {:ok, :noop}

      img ->
        delete_radio_image_file(img)
        Repo.delete(img)
    end
  end

  defp delete_radio_image_file(%RadioImage{image: image} = ri) when not is_nil(image) do
    _ = Myappv1.Uploaders.RadioImage.delete({image, ri})
    :ok
  end

  defp delete_radio_image_file(%RadioImage{}), do: :ok

  @doc """
  Menghapus data radio dari database.
  """
  def delete_radio(%Radio{} = radio) do
    radio = Repo.preload(radio, :radio_images)
    Enum.each(radio.radio_images, &delete_radio_image_file/1)
    Repo.delete(radio)
  end

  @doc """
  Membuat changeset untuk radio (digunakan dalam form untuk validasi dan tracking perubahan).
  attrs adalah map optional yang berisi data yang ingin diubah.
  """
  def change_radio(%Radio{} = radio, attrs \\ %{}) do
    radio = with_tag_ids(radio)
    Radio.changeset(radio, attrs)
  end

  # Mengubah struktur tags menjadi list ID untuk form handling (atau "untuk kenyamanan form handling")
  defp with_tag_ids(%Radio{tags: tags} = radio) when is_list(tags) do
    %{radio | tag_ids: Enum.map(tags, & &1.id)}
  end

  defp with_tag_ids(radio), do: radio

  # ============ HELPER: Mengambil tag berdasarkan tag_ids ============

  # Fungsi ini mengambil tag IDs dari attrs (support string key dan atom key),
  # lalu mencari tag-tag tersebut di database.
  defp tags_for_attrs(attrs) do
    attrs
    |> Map.get("tag_ids", Map.get(attrs, :tag_ids, []))
    |> List.wrap()
    |> Enum.map(&parse_tag_id/1)
    |> Enum.reject(&is_nil/1)
    |> case do
      [] -> []
      ids -> Repo.all(from t in Tag, where: t.id in ^ids)
    end
  end

  # Parse tag_id dari berbagai tipe: integer, binary/string, atau lainnya
  defp parse_tag_id(id) when is_integer(id), do: id

  defp parse_tag_id(id) when is_binary(id) do
    case Integer.parse(id) do
      {int, _} -> int
      _ -> nil
    end
  end

  defp parse_tag_id(_), do: nil

  # ============ FUNGSI CRUD UNTUK CATEGORY ============

  @doc """
  Mengambil semua data kategori dari database.
  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Mengambil satu data kategori berdasarkan ID.
  Jika kategori tidak ditemukan, akan melempar exception Ecto.NoResultsError.
  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Membuat data kategori baru.
  Contoh attrs: %{name: "Handheld", description: "Radio genggam"}
  """
  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Memperbarui data kategori yang sudah ada.
  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Menghapus data kategori dari database.
  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Membuat changeset untuk kategori (digunakan dalam form).
  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Myappv1.Inventory.Tag

  # ============ FUNGSI CRUD UNTUK TAG ============

  @doc """
  Mengambil semua data tag dari database.
  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Mengambil satu data tag berdasarkan ID.
  Jika tag tidak ditemukan, akan melempar exception Ecto.NoResultsError.
  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Membuat data tag baru.
  Contoh attrs: %{name: "VHF", color: "#FF0000"}
  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Memperbarui data tag yang sudah ada.
  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Menghapus data tag dari database.
  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Membuat changeset untuk tag (digunakan dalam form).
  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end
end
