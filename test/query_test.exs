defmodule SimpleRepoNeo4j.QueryTest do
  use ExUnit.Case, async: false # For now
  alias SimpleRepoNeo4j.Query
  alias Support.User

  def clean_up do
    cypher = "MATCH(n) DETACH DELETE(n);"
    Bolt.Sips.query!(Bolt.Sips.conn, cypher)
  end

  describe ".save" do
    @user %User{
      id: 666,
      first_name: "Kira",
      last_name: "Katze",
      favorite_number: 42
    }

    test "writes an item as node to db" do
      clean_up()
      Query.save_node(@user)
      result = Query.get(%User{}, %{id: 666})

      IO.inspect User.__schema__(:type, :id)

      assert {:ok, @user} == result
      clean_up()
    end

    test "writes a small graph" do
      u1 = %User{
        id: 667,
        first_name: "Maya",
        last_name: "Maus",
        favorite_number: 34
      }
      u2 = %User{
        id: 668,
        first_name: "Gina",
        last_name: "Gans",
        favorite_number: 33
      }

      data = [{:node, u1}, {:"-->", :Knows}, {:node, u2}]
      IO.inspect(Query.save(data))
    end
  end
end
