defmodule Myappv1.InventoryTest do
  use Myappv1.DataCase

  alias Myappv1.Inventory

  describe "radios" do
    alias Myappv1.Inventory.Radio

    import Myappv1.InventoryFixtures

    @invalid_attrs %{code: nil, name: nil}

    test "list_radios/0 returns all radios" do
      radio = radio_fixture()
      assert Inventory.list_radios() == [radio]
    end

    test "get_radio!/1 returns the radio with given id" do
      radio = radio_fixture()
      assert Inventory.get_radio!(radio.id) == radio
    end

    test "create_radio/1 with valid data creates a radio" do
      valid_attrs = %{code: "some code", name: "some name"}

      assert {:ok, %Radio{} = radio} = Inventory.create_radio(valid_attrs)
      assert radio.code == "some code"
      assert radio.name == "some name"
    end

    test "create_radio/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_radio(@invalid_attrs)
    end

    test "update_radio/2 with valid data updates the radio" do
      radio = radio_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name"}

      assert {:ok, %Radio{} = radio} = Inventory.update_radio(radio, update_attrs)
      assert radio.code == "some updated code"
      assert radio.name == "some updated name"
    end

    test "update_radio/2 with invalid data returns error changeset" do
      radio = radio_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_radio(radio, @invalid_attrs)
      assert radio == Inventory.get_radio!(radio.id)
    end

    test "delete_radio/1 deletes the radio" do
      radio = radio_fixture()
      assert {:ok, %Radio{}} = Inventory.delete_radio(radio)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_radio!(radio.id) end
    end

    test "change_radio/1 returns a radio changeset" do
      radio = radio_fixture()
      assert %Ecto.Changeset{} = Inventory.change_radio(radio)
    end
  end

  describe "categories" do
    alias Myappv1.Inventory.Category

    import Myappv1.InventoryFixtures

    @invalid_attrs %{name: nil}

    test "list_categories/0 returns all categories" do
      category = category_fixture()
      assert Inventory.list_categories() == [category]
    end

    test "get_category!/1 returns the category with given id" do
      category = category_fixture()
      assert Inventory.get_category!(category.id) == category
    end

    test "create_category/1 with valid data creates a category" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Category{} = category} = Inventory.create_category(valid_attrs)
      assert category.name == "some name"
    end

    test "create_category/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Inventory.create_category(@invalid_attrs)
    end

    test "update_category/2 with valid data updates the category" do
      category = category_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Category{} = category} = Inventory.update_category(category, update_attrs)
      assert category.name == "some updated name"
    end

    test "update_category/2 with invalid data returns error changeset" do
      category = category_fixture()
      assert {:error, %Ecto.Changeset{}} = Inventory.update_category(category, @invalid_attrs)
      assert category == Inventory.get_category!(category.id)
    end

    test "delete_category/1 deletes the category" do
      category = category_fixture()
      assert {:ok, %Category{}} = Inventory.delete_category(category)
      assert_raise Ecto.NoResultsError, fn -> Inventory.get_category!(category.id) end
    end

    test "change_category/1 returns a category changeset" do
      category = category_fixture()
      assert %Ecto.Changeset{} = Inventory.change_category(category)
    end
  end
end
