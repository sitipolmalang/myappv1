defmodule Myappv1.Uploaders.RadioImage do
  use Waffle.Definition
  use Waffle.Ecto.Definition

  @versions [:original]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .webp)

  @async false

  def __storage, do: Waffle.Storage.Local

  def validate({file, _}) do
    ext = file.file_name |> Path.extname() |> String.downcase()

    case Enum.member?(@extension_whitelist, ext) do
      true -> :ok
      false -> {:error, "invalid file type"}
    end
  end

  def storage_dir(_version, {_file, scope}) do
    "uploads/radios/#{scope.radio_id}"
  end

  def filename(_version, {file, scope}) do
    ext = Path.extname(file.file_name)
    "slot_#{scope.slot}#{ext}"
  end
end
