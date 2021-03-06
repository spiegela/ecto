defmodule Ecto.Adapters.Postgres.TypeMapTest do
  use ExUnit.Case, async: true
  require Ecto.Adapters.Postgres.TypeMap, as: T

  test "string",   do: assert T.for(:string)   == :text 
  test "binary",   do: assert T.for(:binary)   == :text
  test "datetime", do: assert T.for(:datetime) == :timestamp
  test "integer",  do: assert T.for(:integer)  == :integer
  test "boolean",  do: assert T.for(:boolean)  == :boolean

  test "handles strings" do
    assert T.for("string") == :text
  end

  test "handles custom ID type" do
    assert T.for(:id) == :'serial primary key'
  end
end
