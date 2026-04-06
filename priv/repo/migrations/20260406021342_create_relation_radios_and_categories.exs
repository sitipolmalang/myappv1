defmodule Myappv1.Repo.Migrations.CreateRelationRadiosAndCategories do
  use Ecto.Migration

  def change do
    alter table(:radios) do
      add :category_id, references(:categories, on_delete: :nilify_all)
    end

    create index(:radios, [:category_id])
  end
end
