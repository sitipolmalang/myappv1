# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Myappv1.Repo.insert!(%Myappv1.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query
alias Myappv1.Repo
alias Myappv1.Inventory

# Hapus data existing untuk menghindari duplikat saat menjalankan ulang seeder
Repo.delete_all(from c in Inventory.Category, where: c.id > 0)
Repo.delete_all(from t in Inventory.Tag, where: t.id > 0)

# ============ SEED CATEGORIES ============
category_names = [
  "Handheld",
  "Base Station",
  "Mobile",
  "Repeater",
  "Scanning",
]

for name <- category_names do
  Inventory.create_category(%{name: name})
end

# ============ SEED TAGS ============
tag_names = [
  "VHF",
  "UHF",
  "HF",
  "DMR",
  "Analog",
  "Digital",
  "PMR446",
  "CB Radio",
  "Amateur",
  "Commercial",
]

for name <- tag_names do
  Inventory.create_tag(%{name: name})
end

IO.puts("Seeded #{length(category_names)} categories and #{length(tag_names)} tags!")
