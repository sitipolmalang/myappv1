# Fitur Upload Gambar Radio

Implementasi upload gambar untuk radio dengan menggunakan Waffle (storage) dan Mogify (image processing).

## Deskripsi

- Radio dapat memiliki maksimal 3 gambar
- Gambar disimpan di local storage (`priv/static/uploads`)
- Support resize otomatis (thumb, medium, original)
- Fleksibel untuk migrate ke cloud storage di kemudian hari

---

## Step 1: Install Dependency

Tambahkan dependency di `mix.exs`:

```elixir
def deps do
  [
    {:waffle, "~> 1.1"},
    {:waffle_ecto, "~> 0.0"},
    {:mogify, "~> 1.0"}
  ]
end
```

Jalankan:
```bash
mix deps.get
```

**Catatan:**
- `waffle` - untuk handle upload dan storage
- `waffle_ecto` - untuk menyimpan metadata gambar di Ecto
- `mogify` - untuk resize dan convert gambar

---

## Step 2: Buat Storage Adapter (Waffle)

File: `lib/myappv1_web/storage.ex`

```elixir
defmodule Myappv1Web.Storage do
  use Waffle.Storage.Local,
    bucket: Application.get_env(:myappv1, :uploads_path, "priv/static/uploads"),
    endpoint: Application.get_env(:myappv1, :uploads_endpoint, "/uploads")
end
```

---

## Step 3: Buat Image Definition (Mogify)

File: `lib/myappv1/inventory/image.ex`

```elixir
defmodule Myappv1.Inventory.Image do
  use Mogify.Definition

  @versions [:original, :thumb, :medium]

  def transform(:thumb, _), do: "150x150"
  def transform(:medium, _), do: "400x400"

  # Konversi ke WebP (lebih kecil, kualitas baik)
  def transform(:original, _), do: {:convert, "-format webp -quality 85"}

  def validate({file, _}) do
    ext = file.file_name |> Path.extname() |> String.downcase()
    Enum.member?(~w(.jpg .jpeg .png .gif .webp), ext)
  end

  def storage_dir(_, {_, scope}) do
    "uploads/radios/#{scope.id}"
  end

  def process(:original, {file, _}), do: file
  def process(:thumb, {file, _}), do: Mogify.resize(file, "150x150")
  def process(:medium, {file, _}), do: Mogify.resize(file, "400x400")

  def module, do: __MODULE__
  def default_version, do: :original
end
```

**Catatan WebP:**
- Format `{:convert, "-format webp -quality 85"}` mengkonversi ke WebP dengan kualitas 85%
- **Local**: ImageMagick opsional untuk development
- **Production**: ImageMagick harus terinstall di server
- **Alternatif tanpa ImageMagick**: Gunakan Cloudinary (oke otomatis proses)
- File lebih kecil ~30% dari JPEG dengan kualitas setara

---

## Step 4: Update Schema Radio

File: `lib/myappv1/inventory/radio.ex`

Tambahkan field:
```elixir
field :images, {:array, :string}
field :images_uploads, {:any, :any}, virtual: true
```

Changeset:
```elixir
def changeset(radio, attrs) do
  radio
  |> cast(attrs, [:name, :code, :category_id, :images, :images_uploads])
  |> validate_required([:name, :code])
  # ...
end
```

---

## Step 4b: Buat Schema untuk Metadata Gambar (Waffle.Ecto)

File: `lib/myappv1/inventory/radio_image.ex`

```elixir
defmodule Myappv1.Inventory.RadioImage do
  use Ecto.Schema
  use Waffle.Ecto.Schema

  @primary_key false
  schema "radio_images" do
    field :upload, Myappv1.Inventory.Image.Type
    field :remote_id, :string
    field :version, :string
    timestamps()
  end

  waffle_versions do
    version :original
    version :thumb
    version :medium
  end
end
```

**Fungsi waffle_ecto:**
- Otomatis generate berbagai versi gambar
- Track metadata: filename, size, hash
- Query gambar berdasarkan versi

---

## Step 5: Buat Migration

```bash
mix ecto.gen.migration add_images_to_radios
```

Isi migration:
```elixir
alter table(:radios) do
  add :images, {:array, :string}, default: []
end
```

Jalankan:
```bash
mix ecto.migrate
```

---

## Step 6: Update Inventory Context

File: `lib/myappv1/inventory.ex`

Update `create_radio` dan `update_radio` untuk proses upload:
```elixir
defp process_images(%{"images" => images}) do
  # Process upload dengan Waffle
end
```

---

## Step 7: Update LiveView Form

File: `lib/myappv1_web/live/radio_live/form.ex`

- Tambahkan input file untuk upload gambar
- Tampilkan preview gambar yang diupload
- Validasi max 3 gambar

---

## Step 8: Update View/Templates

### Radio Index
- Tampilkan thumbnail pertama

### Radio Show
- Gallery dengan 3 gambar
- Lightbox untuk preview

---

## Referensi

- [Waffle](https://hex.pm/packages/waffle)
- [Mogify](https://hex.pm/packages/mogify)

---

## Catatan Environment

### Local Development
- ImageMagick opsional jika tidak pakai WebP
- Jika pakai WebP, install: https://imagemagick.org/script/download.php

### Production Server
- ImageMagick WAJIB jika pakai WebP conversion
- Atau ganti ke Cloudinary (tidak perlu ImageMagick)