defmodule Myappv1.Repo.Migrations.CreateRadios do
  use Ecto.Migration

  def change do
    create table(:radios) do
      add :name, :string
      add :code, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:radios, [:code])
  end
end
