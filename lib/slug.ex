defmodule Slug do
  @moduledoc """
  Slugify a string.
  """
  import Codepagex, only: [replace_nonexistent: 1, to_string: 3]
  require Logger
  alias Ecto.Changeset

  @doc """
  Takes a string and slugifies it.

  ## Examples

      iex> Slug.slugify("This'll slug")
      "thisll-slug"

      iex> Slug.slugify("What (2000-2011)")
      "what-2000-2011"

      iex> Slug.slugify("")
      nil

  """
  @spec slugify(binary()) ::
          binary()

  def slugify(nil), do: nil
  def slugify(""), do: nil
  def slugify(text) when is_binary(text) do
    text
    |> replace_characters()
    |> Slugger.slugify_downcase()
  rescue
    UnicodeConversionError ->
      Logger.error "Problem slugifying text: #{inspect text}"

      text
      |> replace_characters()
      |> remove_illegal_characters()
      |> Slugger.slugify_downcase()
  end

  defp replace_characters(text) do
    text
    |> String.replace("%", "pc")
    |> String.replace(~r/[£$€'‘’]/u, "")
  end

  defp remove_illegal_characters(text) do
    case to_string(text, :iso_8859_1, replace_nonexistent("_")) do
      {:ok, new_text, _} -> new_text
      {:error, _, _}     -> text
    end
  end

  @doc """
  Takes a field name and a changeset and will update the slug with the slugified
  version of the requested field.

  ## Examples

      iex> slugify_field(%Ecto.Changeset{changes: %{name: "Test This"}}, :name, :slug)
      %Ecto.Changeset{changes: %{name: "Test This", slug: "test-this"}}

  """
  @typep source_field :: atom()
  @typep target_field :: atom()
  @typep changeset :: Ecto.Changeset.t()

  @spec slugify_field(changeset(), source_field(), target_field(), opts :: list()) ::
          changeset()

  def slugify_field(chset, source_field, target_field \\ :slug, opts \\ [force: false])
  def slugify_field(chset, source_field, target_field, opts) do
    source_text = Changeset.get_field(chset, source_field)
    target_text = Changeset.get_field(chset, target_field)

    if has_source?(source_text) && should_update_target?(target_text, opts) do
      Changeset.put_change(chset, target_field, slugify(source_text))
    else
      chset
    end
  end

  defp should_update_target?(target, [force: force]), do: is_nil(target) || force

  defp has_source?(nil), do: false
  defp has_source?(""), do: false
  defp has_source?(_), do: true

end
