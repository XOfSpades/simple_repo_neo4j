defmodule SimpleRepoNeo4j.Query do
  alias Bolt.Sips, as: Bolt

  def save(data_list) do
    save(data_list, [], "CREATE ")
  end
  def save([], returning, cypher) do
    query = cypher <> "RETURN " <> (returning |> Enum.reverse |> Enum.join(", ")) <> ";"
    IO.puts "\n\n\n#{query} \n\n\n"
    Bolt.query(Bolt.conn, query)
  end
  def save([item| data_list], returning,  cypher) do
    IO.inspect item
    case item do
      {:node, struct} ->
        node_name = "item#{length(returning)}"
        save(
          data_list,
          [node_name| returning],
          cypher <> "(#{node_name}:#{node_type(struct)} { #{params_to_query(struct)} }) "
        )
      {:"-->", struct} ->
        save(
          data_list,
          returning,
          cypher <> "-[:#{node_type(struct)} { #{params_to_query(struct)} } ]-> "
        )
      {:">--", struct} ->
        save(
          data_list,
          returning,
          cypher <> "<-[:#{node_type(struct)} { #{params_to_query(struct)} } ]- "
        )
      {:"--", struct} ->
        save(
          data_list,
          returning,
          cypher <> "-[:#{node_type(struct)} { #{params_to_query(struct)} } ]- "
        )
    end
  end

  def save_node(struct) do
    cypher = """
      CREATE (item:#{node_type(struct)} { #{params_to_query(struct)} })
      RETURN(item);
    """
    Bolt.query(Bolt.conn, cypher)
  end

  def save_rel(rel_struct, from_node, to_node) do

  end

  def get(vertex, params) do
    cypher = """
      Match(item:#{node_type(vertex)}) #{conditions_by_params(params)}
      RETURN item
    """

    case Bolt.query(Bolt.conn, cypher, params) do
      {:error, msg} -> {:error, msg}
      {:ok, []} -> {:error, "Not found"}
      {:ok, [%{"item" => %{properties: properties}}]} ->
        # x = Enum.reduce(
        #   properties,
        #   %{},
        #   fn {key, value}, acc ->
        #     atom_key = String.to_existing_atom(key)
        #     Map.put(acc, atom_key, value)
        #   end
        # )
        {:ok, to_struct(vertex, properties)}
      {:ok, _} -> {:error, "Query returned more than one item"}
    end

  end

  def get_all(vertex), do: get_all(vertex, [])
  def get_all(vertex, []) do
    cypher = """
      MATCH (m:#{node_type(vertex)})
      RETURN m
    """

    Bolt.query(Bolt.conn, cypher)
  end
  def get_all(vertex, params) when is_list(params) or is_map(params) do
    cypher = """
      Match(item:#{node_type(vertex)}) #{conditions_by_params(params)}
      RETURN item
    """

    Bolt.query(Bolt.conn, cypher, params)
  end

  defp params_to_query(params) when is_map(params) do
    params
    |> Map.drop([:__struct__, :__meta__])
    |> Enum.filter(fn {_key, value} -> !is_nil(value) end)
    |> Enum.map(fn {key, value} -> "#{key}:\"#{value}\"" end)
    |> Enum.join(", ")
  end
  defp params_to_query(params), do: ""

  defp conditions_by_params(%{}), do: ""
  defp conditions_by_params([]), do: ""
  defp conditions_by_params(params) do
    conditions = params
    |> Enum.reduce([], fn {key, _value} -> "item.#{key} = $key" end)
    |> Enum.join(" AND ")

    "WHERE #{conditions}"
  end

  defp node_type(%{__struct__: struct_name} = struct) do
    case struct_name |> Atom.to_string |> String.replace(".", "_") do
      "Elixir_" <> type -> type
      type -> type
    end
  end
  defp node_type(name) when is_atom(name) or is_binary(name), do: "#{name}"

  def type(struct, field), do: struct.__struct__.__schema__(:type, field)

  defp to_struct(struct, params) do
    atom_map = params
    |> Enum.map(fn {key, value} ->
      atom_key = String.to_existing_atom(key)
      {
        atom_key,
        cast(struct.__struct__, atom_key, value)
      }
    end)
    |> Enum.into(%{})
    Map.merge(struct, atom_map)
  end

  defp cast(struct, key, value) do
    # IO.inspect struct
    case struct.__schema__(:type, key) do
      :string -> value
      :integer -> String.to_integer(value)
      :float -> String.to_float(value)
    end
  end

  defp value_with_type(vertex, key, value) do
    case type(vertex, key) do
      :integer ->
    end
  end
end

#CREATE (Node {msg:"test message"})

#Match(l42:Node) RETURN l42;
#Match(#{id}:#{vertex})
