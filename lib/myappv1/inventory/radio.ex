defmodule Myappv1.Inventory.Radio do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radios" do
    field :name, :string
    field :code, :string
    field :tag_ids, {:array, :integer}, virtual: true

    belongs_to :category, Myappv1.Inventory.Category
    many_to_many :tags, Myappv1.Inventory.Tag, join_through: "radios_tags", on_replace: :delete
    has_many :radio_images, Myappv1.Inventory.RadioImage
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(radio, attrs) do
    radio
    |> cast(attrs, [:name, :code, :category_id, :tag_ids])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> foreign_key_constraint(:category_id)
  end
end
