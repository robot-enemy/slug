defmodule SlugTest do
  @moduledoc false
  use ExUnit.Case
  import ExUnit.CaptureLog

  describe "slugify/1" do

    test "when given a string, slugs it" do
      assert Slug.slugify("My Test String") == "my-test-string"
      assert Slug.slugify("A Title's Year (2000-2001)") == "a-titles-year-2000-2001"
      assert Slug.slugify("What is \"this\"") == "what-is-this"
      assert Slug.slugify("YOU `crazy` FOOL") == "you-crazy-fool"
      assert Slug.slugify("The $1,000,000 Question") == "the-1-000-000-dollar-question"
      assert Slug.slugify("Hei$t") == "heist"
      assert Slug.slugify("The £1,000,000 Con") == "the-1-000-000-pound-con"
      assert Slug.slugify("EU to use €2.4bn of carbon credit") == "eu-to-use-2-4bn-euro-of-carbon-credit"
      assert Slug.slugify("Liverpool close €100m deal") == "liverpool-close-100m-euro-deal"
      assert Slug.slugify("UK fears locked out €100 billion research") == "uk-fears-locked-out-100-billion-euro-research"
    end

    test "when given an empty string, returns nil" do
      assert Slug.slugify("") |> is_nil()
    end

    test "when given an invalid string, attempts to remove the invalid chars" do
      invalid_byte_sequence = "\x80\x81"
      assert capture_log(fn ->
        assert Slug.slugify(invalid_byte_sequence) == ""
      end) =~ "Problem slugifying text"

      invalid_byte_sequence = "EMMANUEL PE\xc3\u0192\xc2\u2018A GOMEZ PORTUGAL"
      assert capture_log(fn ->
        assert Slug.slugify(invalid_byte_sequence) == "emmanuel-pea-gomez-portugal"
      end) =~ "Problem slugifying text"
    end

  end

  defp changeset(params, types \\ %{slug: :string, title: :string}) do
    {%{}, types}
    |> Ecto.Changeset.cast(params, Map.keys(types))
  end

  describe "slugify_field/4" do

    test "when given a changeset, slugs the given field to the slug column" do
      chset = changeset(%{title: "My Test String"})
      assert %Ecto.Changeset{} = chset = Slug.slugify_field(chset, :title)
      assert chset.changes.slug == "my-test-string"
    end

    test "when given a target_field, slugifies the source to the target" do
      chset = changeset(%{post_title: "This're (title)"}, %{post_title: :string, post_slug: :string})
      assert %Ecto.Changeset{} = chset = Slug.slugify_field(chset, :post_title, :post_slug)
      assert chset.changes.post_slug == "thisre-title"
    end

    test "when slug already exists, don't update" do
      chset =
        {%{title: "Title 1", slug: "slug-1"}, %{title: :string, slug: :string}}
        |> Ecto.Changeset.cast(%{title: "New Title"}, [:title])

      assert %Ecto.Changeset{} = chset = Slug.slugify_field(chset, :title)
      refute Map.has_key?(chset.changes, :slug)
    end

    test "When slug exists, update if force option is passed" do
      chset =
        {%{title: "Title 1", slug: "slug-1"}, %{title: :string, slug: :string}}
        |> Ecto.Changeset.cast(%{title: "New Title"}, [:title])

      assert %Ecto.Changeset{} = chset = Slug.slugify_field(chset, :title, :slug, force: true)
      assert chset.changes.slug == "new-title"
    end

  end

end
