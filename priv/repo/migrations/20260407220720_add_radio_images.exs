defmodule Myappv1.Repo.Migrations.AddRadioImages do
  use Ecto.Migration

  def change do
    create table(:radio_images) do
      add :radio_id, references(:radios, on_delete: :delete_all), null: false
      add :slot, :integer, null: false
      add :image, :string, null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:radio_images, [:radio_id, :slot])
  end
end
