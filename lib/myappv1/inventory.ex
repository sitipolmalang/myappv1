defmodule Myappv1.Inventory do
  @moduledoc """
  The Inventory context.
  """

  import Ecto.Query, warn: false
  alias Myappv1.Repo

  alias Myappv1.Inventory.Radio
  alias Myappv1.Inventory.Category

  @doc """
  Returns the list of radios.

  ## Examples

      iex> list_radios()
      [%Radio{}, ...]

  """
  def list_radios do
    Repo.all(Radio)
    |> Repo.preload(:category)

  end

  @doc """
  Gets a single radio.

  Raises `Ecto.NoResultsError` if the Radio does not exist.

  ## Examples

      iex> get_radio!(123)
      %Radio{}

      iex> get_radio!(456)
      ** (Ecto.NoResultsError)

  """
  def get_radio!(id) do
    Repo.get!(Radio, id)
    |> Repo.preload(:category)
  end

  @doc """
  Creates a radio.

  ## Examples

      iex> create_radio(%{field: value})
      {:ok, %Radio{}}

      iex> create_radio(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_radio(attrs) do
    %Radio{}
    |> Radio.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a radio.

  ## Examples

      iex> update_radio(radio, %{field: new_value})
      {:ok, %Radio{}}

      iex> update_radio(radio, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_radio(%Radio{} = radio, attrs) do
    radio
    |> Radio.changeset(attrs)
    |> Repo.update()
    |> case do
      {:ok, radio} -> {:ok, Repo.preload(radio, :category)}
      error -> error
    end
  end

  @doc """
  Deletes a radio.

  ## Examples

      iex> delete_radio(radio)
      {:ok, %Radio{}}

      iex> delete_radio(radio)
      {:error, %Ecto.Changeset{}}

  """
  def delete_radio(%Radio{} = radio) do
    Repo.delete(radio)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking radio changes.

  ## Examples

      iex> change_radio(radio)
      %Ecto.Changeset{data: %Radio{}}

  """
  def change_radio(%Radio{} = radio, attrs \\ %{}) do
    Radio.changeset(radio, attrs)
  end

  @doc """
  Returns the list of categories.

  ## Examples

      iex> list_categories()
      [%Category{}, ...]

  """
  def list_categories do
    Repo.all(Category)
  end

  @doc """
  Gets a single category.

  Raises `Ecto.NoResultsError` if the Category does not exist.

  ## Examples

      iex> get_category!(123)
      %Category{}

      iex> get_category!(456)
      ** (Ecto.NoResultsError)

  """
  def get_category!(id), do: Repo.get!(Category, id)

  @doc """
  Creates a category.

  ## Examples

      iex> create_category(%{field: value})
      {:ok, %Category{}}

      iex> create_category(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_category(attrs) do
    %Category{}
    |> Category.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a category.

  ## Examples

      iex> update_category(category, %{field: new_value})
      {:ok, %Category{}}

      iex> update_category(category, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_category(%Category{} = category, attrs) do
    category
    |> Category.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a category.

  ## Examples

      iex> delete_category(category)
      {:ok, %Category{}}

      iex> delete_category(category)
      {:error, %Ecto.Changeset{}}

  """
  def delete_category(%Category{} = category) do
    Repo.delete(category)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking category changes.

  ## Examples

      iex> change_category(category)
      %Ecto.Changeset{data: %Category{}}

  """
  def change_category(%Category{} = category, attrs \\ %{}) do
    Category.changeset(category, attrs)
  end

  alias Myappv1.Inventory.Tag

  @doc """
  Returns the list of tags.

  ## Examples

      iex> list_tags()
      [%Tag{}, ...]

  """
  def list_tags do
    Repo.all(Tag)
  end

  @doc """
  Gets a single tag.

  Raises `Ecto.NoResultsError` if the Tag does not exist.

  ## Examples

      iex> get_tag!(123)
      %Tag{}

      iex> get_tag!(456)
      ** (Ecto.NoResultsError)

  """
  def get_tag!(id), do: Repo.get!(Tag, id)

  @doc """
  Creates a tag.

  ## Examples

      iex> create_tag(%{field: value})
      {:ok, %Tag{}}

      iex> create_tag(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_tag(attrs) do
    %Tag{}
    |> Tag.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a tag.

  ## Examples

      iex> update_tag(tag, %{field: new_value})
      {:ok, %Tag{}}

      iex> update_tag(tag, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_tag(%Tag{} = tag, attrs) do
    tag
    |> Tag.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a tag.

  ## Examples

      iex> delete_tag(tag)
      {:ok, %Tag{}}

      iex> delete_tag(tag)
      {:error, %Ecto.Changeset{}}

  """
  def delete_tag(%Tag{} = tag) do
    Repo.delete(tag)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking tag changes.

  ## Examples

      iex> change_tag(tag)
      %Ecto.Changeset{data: %Tag{}}

  """
  def change_tag(%Tag{} = tag, attrs \\ %{}) do
    Tag.changeset(tag, attrs)
  end
end
