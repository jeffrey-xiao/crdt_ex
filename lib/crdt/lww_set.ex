defmodule Crdt.LWWSet do
  defstruct a_map: %{}, r_map: %{}, bias: :add

  def new(bias), do: %__MODULE__{a_map: %{}, r_map: %{}, bias: bias}

  def merge(s1, s2) do
    if s1.bias != s2.bias do
      raise "Maps must have equal biases."
    end

    %__MODULE__{
      a_map: map_merge(s1.a_map, s2.a_map),
      r_map: map_merge(s1.r_map, s2.r_map),
      bias: s1.bias
    }
  end

  defp map_merge(m1, m2) do
    (Map.keys(m1) ++ Map.keys(m2))
    |> Stream.uniq()
    |> Stream.map(fn item -> {item, map_max(m1[item], m2[item])} end)
    |> Enum.into(%{})
  end

  defp map_max(item1, item2) do
    case {item1, item2} do
      {nil, item2} -> item2
      {item1, nil} -> item1
      {item1, item2} when item1 > item2 -> item1
      _ -> item2
    end
  end

  defp map_set(map, item, timestamp) do
    Map.put(map, item, map_max(map[item], timestamp))
  end

  def add(set, item, timestamp) do
    %{set | a_map: map_set(set.a_map, item, timestamp)}
  end

  def remove(set, item, timestamp) do
    %{set | r_map: map_set(set.r_map, item, timestamp)}
  end

  def member?(set, item) do
    a_item = set.a_map[item]
    r_item = set.r_map[item]

    cond do
      a_item == nil -> false
      r_item == nil -> true
      a_item > r_item -> true
      a_item < r_item -> false
      true -> set.bias == :add
    end
  end
end
