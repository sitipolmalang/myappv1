defmodule Myappv1.InventoryFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Myappv1.Inventory` context.
  """

  @doc """
  Generate a unique radio code.
  """
  def unique_radio_code, do: "some code#{System.unique_integer([:positive])}"

  @doc """
  Generate a radio.
  """
  def radio_fixture(attrs \\ %{}) do
    {:ok, radio} =
      attrs
      |> Enum.into(%{
        code: unique_radio_code(),
        name: "some name"
      })
      |> Myappv1.Inventory.create_radio()

    radio
  end

  @doc """
  Generate a unique category name.
  """
  def unique_category_name, do: "some name#{System.unique_integer([:positive])}"

  @doc """
  Generate a category.
  """
  def category_fixture(attrs \\ %{}) do
    {:ok, category} =
      attrs
      |> Enum.into(%{
        name: unique_category_name()
      })
      |> Myappv1.Inventory.create_category()

    category
  end
end
