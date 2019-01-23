defmodule Crdt.LWWSet do
  @moduledoc """
  A LWW-Set is set that supports removal and insertion of items an arbitrary number of times, but
  client must provide timestamps for these events. The set can be tuned in a way that it is biased
  towards adds or deletes, if an add operation occurs at the same timstamp of a remove operation.
  """
  defstruct a_map: %{}, r_map: %{}, bias: :add

  @type bias :: :add | :remove
  @type value_map :: %{any() => any()}
  @type t :: %__MODULE__{a_map: value_map, r_map: value_map, bias: bias}

  @doc """
  Returns a new, empty LWW-Set.
  """
  @spec new(bias) :: t
  def new(bias), do: %__MODULE__{a_map: %{}, r_map: %{}, bias: bias}

  @doc """
  Merges `s1` and `s2`.
  """
  @spec merge(t, t) :: t
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

  @spec map_merge(value_map, value_map) :: value_map
  defp map_merge(m1, m2),
    do: Map.merge(m1, m2, fn _item, timestamp1, timestamp2 -> max(timestamp1, timestamp2) end)

  @spec map_max(any(), any()) :: any()
  defp map_max(item1, item2) do
    case {item1, item2} do
      {nil, item2} -> item2
      {item1, nil} -> item1
      {item1, item2} when item1 > item2 -> item1
      _ -> item2
    end
  end

  @spec map_set(value_map(), any(), any()) :: value_map()
  defp map_set(map, item, timestamp) do
    Map.put(map, item, map_max(map[item], timestamp))
  end

  @doc """
  Adds `item` to `set` at `timestamp`.
  """
  @spec add(t, any(), any()) :: t
  def add(set, item, timestamp) do
    %{set | a_map: map_set(set.a_map, item, timestamp)}
  end

  @doc """
  Adds `item` to `set` at `timestamp`.
  """
  @spec remove(t, any(), any()) :: t
  def remove(set, item, timestamp) do
    %{set | r_map: map_set(set.r_map, item, timestamp)}
  end

  @doc """
  Returns all items in `set`.
  """
  @spec get(t) :: MapSet.t(any())
  def get(set) do
    set.a_map
    |> Stream.filter(fn {item, a_timestamp} ->
      case set.r_map[item] do
        nil -> true
        r_timestamp ->
          cond do
            a_timestamp > r_timestamp -> true
            a_timestamp < r_timestamp -> false
            true -> set.bias == :add
          end
      end
    end)
    |> Stream.map(fn {item, _a_timestamp} -> item end)
    |> Enum.into(MapSet.new())
  end

  @doc """
  Returns `true` if `item` is a member of `set`.
  """
  @spec member?(t, any()) :: boolean()
  def member?(set, item) do
    a_timestamp = set.a_map[item]
    r_timestamp = set.r_map[item]

    cond do
      a_timestamp == nil -> false
      r_timestamp == nil -> true
      a_timestamp > r_timestamp -> true
      a_timestamp < r_timestamp -> false
      true -> set.bias == :add
    end
  end
end
