defmodule Crdt.LWWSet do
  @moduledoc """
  A LWW-Set is set that supports removal and insertion of items an arbitrary number of times, but
  client must provide timestamps for these events. The set can be tuned in a way that it is biased
  towards adds or deletes, if an add operation occurs at the same timstamp of a remove operation.
  """
  defstruct a_map: %{}, r_map: %{}, bias: :add

  @doc """
  Returns a new, empty LWW-Set.
  """
  def new(bias), do: %__MODULE__{a_map: %{}, r_map: %{}, bias: bias}

  @doc """
  Merges `s1` and `s2`.
  """
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

  @doc """
  Adds `item` to `set` at `timestamp`.
  """
  def add(set, item, timestamp) do
    %{set | a_map: map_set(set.a_map, item, timestamp)}
  end

  @doc """
  Adds `item` to `set` at `timestamp`.
  """
  def remove(set, item, timestamp) do
    %{set | r_map: map_set(set.r_map, item, timestamp)}
  end

  @doc """
  Returns `true` if `item` is a member of `set`.
  """
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
