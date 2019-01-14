defmodule Crdt.VectorClock do
  def new() do
    %{}
  end

  def descends?(_, %{}), do: true

  def descends?(v1, v2) do
    Enum.all(v2, fn {id, timestamp2} ->
      case v1[id] do
        timestamp1 -> timestamp1 >= timestamp2
        nil -> false
      end
    end)
  end

  def dominates?(v1, v2), do: descends?(v1, v2) && !descends?(v2, v1)

  def forget(v1, v2) do
    Enum.filter(v1, fn {id, timestamp} -> timestamp < get_timestamp(v2, id) end)
  end

  def merge(v1, v2) do
    (Map.keys(v1) ++ Map.keys(v2))
    |> Stream.uniq()
    |> Stream.map(fn id -> max(get_timestamp(v1, id), get_timestamp(v2, id)) end)
    |> Enum.into(%{})
  end

  def greatest_lower_bound(v1, v2) do
    v1
    |> Enum.filter(fn {id, _timestamp} -> v2[id] != nil end)
    |> Enum.map(fn {id, timestamp} -> min(timestamp, v2[id]) end)
    |> Enum.into(%{})
  end

  def get_timestamp(v, id) do
    case v[id] do
      nil -> 0
      timestamp -> timestamp
    end
  end

  def increment_timestamp(v, id) do
    Map.put(v, get_timestamp(v, id) + 1)
  end
end
