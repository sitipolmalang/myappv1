defmodule Myappv1.Inventory.Radio do
  use Ecto.Schema
  import Ecto.Changeset

  schema "radios" do
    field :name, :string
    field :code, :string

    belongs_to :category, Myappv1.Inventory.Category
    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(radio, attrs) do
    radio
    |> cast(attrs, [:name, :code, :category_id])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
    |> foreign_key_constraint(:category_id)
  end
end
