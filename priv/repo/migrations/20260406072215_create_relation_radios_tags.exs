defmodule Myappv1.Repo.Migrations.CreateRelationRadiosTags do
  use Ecto.Migration

  def change do
    create table(:radios_tags, primary_key: false) do
      add(:radio_id, references(:radios, on_delete: :delete_all), null: false)
      add(:tag_id, references(:tags, on_delete: :delete_all), null: false)
    end

    create(index(:radios_tags, [:radio_id]))
    create(index(:radios_tags, [:tag_id]))
    create(unique_index(:radios_tags, [:radio_id, :tag_id]))
  end
end
