defmodule Mix.Tasks.Ecto.Gen.Model.Entity do
  use Mix.Task

  import Mix.Tasks.Ecto
  import Mix.Generator
  import Mix.Utils, only: [camelize: 1, underscore: 1]

  @shortdoc "Generates an ecto model and entity"

  @moduledoc """
  Generates a model and entity for a given repo.

  ## Examples

      mix ecto.gen.model.entity MyApp.Repo MyModel

  """

  def run(args) do
    case parse_repo(args) do
      { repo, [model_name|field_specs] } ->
        ensure_repo(repo)
        params = get_params(repo, model_name, field_specs)

        create_file_with_dir(params[:file_name], &model_template/1, params)
        Mix.Tasks.Compile.run [params[:file_name]]

        create_file_with_dir(params[:test_file_name], &test_template/1, params)
      { _repo, _ } ->
        raise Mix.Error, message:
              "expected ecto.gen.model.entity to receive the repo and model name, got: #{inspect Enum.join(args, " ")}"
    end
  end

  defp get_params(repo, model_name, field_specs) do
    # Get short repo name
    {:ok, repo_name} = to_string(repo) |> String.split(".") |> Enum.fetch(-1)

    underscored = model_name |> underscore
    [ module_name: model_name,
      table_name: (repo_name <> model_name) |> String.replace(".", "")|> underscore,
      file_name: Path.join("lib", underscored) <> ".ex",
      test_file_name: Path.join("test", underscored) <> "_test.exs",
      fields: Enum.map(field_specs, &field_from_spec(&1))
    ]
  end

  defp field_from_spec(spec) do
    [name, type] = String.split(spec, ":")
    "  field :#{name }, :#{type }"
  end

  embed_template :model, """
  defmodule <%= @module_name %> do
    use Ecto.Model

    queryable "<%= @table_name %>" do
      <%= Enum.join(@fields, "\n      ") %>
    end
  end
  """

  embed_template :test, """
  defmodule <%= @module_name %>Test do
    # Test cases interacting with the DB most be async.
    # If your test cases don't, feel free to enable async.
    use ExUnit.Case, async: false

    test "the truth" do
      assert true
    end
  end
  """
 end
