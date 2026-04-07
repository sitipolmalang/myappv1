defmodule Myappv1.Inventory.RadioImage do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  alias Myappv1.Inventory.Radio

  schema "radio_images" do
    field :slot, :integer
    field :image, Myappv1.Uploaders.RadioImage.Type
    belongs_to :radio, Radio
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(radio_image, attrs) do
    radio_image
    |> cast(attrs, [:radio_id, :slot])
    |> validate_required([:radio_id, :slot])
    |> validate_number(:slot, greater_than_or_equal_to: 1, less_than_or_equal_to: 3)
    |> cast_attachments(attrs, [:image])
    |> validate_required([:image])
    |> foreign_key_constraint(:radio_id)
    |> unique_constraint([:radio_id, :slot])
  end
end
