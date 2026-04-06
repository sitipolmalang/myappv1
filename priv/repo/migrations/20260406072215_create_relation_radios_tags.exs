defmodule Myappv1.Repo.Migrations.CreateRelationRadiosTags do
  use Ecto.Migration

  def change do
    create table(:radios_tags, primary_key: false) do
      add(:radios_id, references(:radios, on_delete: :delete_all), null: false)
      add(:tags_id, references(:tags, on_delete: :delete_all), null: false)
    end

    create(index(:radios_tags, [:radios_id]))
    create(index(:radios_tags, [:tags_id]))
    create(unique_index(:radios_tags, [:radios_id, :tags_id]))

  end
end
