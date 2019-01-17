defmodule Crdt.VectorClock do
  @moduledoc """
  A Vector Clock is capable of generating a partial ordering of events in a distributed system and
  detecting causality vioations. It is essentially a map of actors to their logical clock value.
  """

  @type t :: %{any() => non_neg_integer()}

  @doc """
  Returns a new, empty Vector Clock.
  """
  @spec new() :: t
  def new() do
    %{}
  end

  @doc """
  Returns `true` if `v1` is a direct descendent of `v2`. Note that a vector clock is its own
  descendent.
  """
  @spec descends?(t, t) :: boolean()
  def descends?(_v1, v2) when v2 == %{}, do: true

  def descends?(v1, v2) do
    Enum.all?(v2, fn {id, timestamp2} ->
      case v1[id] do
        nil -> false
        timestamp1 -> timestamp1 >= timestamp2
      end
    end)
  end

  @doc """
  Returns `true` if `v1` descends `v2` and `v1` does not equal `v2`.
  """
  @spec dominates?(t, t) :: boolean()
  def dominates?(v1, v2), do: descends?(v1, v2) && !descends?(v2, v1)

  @doc """
  Returns `true` if `v1` and `v2` have diverged.
  """
  @spec concurrent?(t, t) :: boolean()
  def concurrent?(v1, v2), do: !descends?(v1, v2) && !descends?(v2, v1)

  @doc """
  Forget any actors in `v1` that have smaller counts than the count in `v2`.
  """
  @spec forget(t, t) :: t
  def forget(v1, v2) do
    v1
    |> Enum.filter(fn {id, timestamp} -> timestamp >= get(v2, id) end)
    |> Enum.into(%{})
  end

  @doc """
  Merges `v1` and `v2`.
  """
  @spec merge(t, t) :: t
  def merge(v1, v2) do
    (Map.keys(v1) ++ Map.keys(v2))
    |> Stream.uniq()
    |> Stream.map(fn id -> {id, max(get(v1, id), get(v2, id))} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the greatest-lower-bound of `v1` and `v2`.
  """
  @spec greatest_lower_bound(t, t) :: t
  def greatest_lower_bound(v1, v2) do
    v1
    |> Enum.filter(fn {id, _timestamp} -> v2[id] != nil end)
    |> Enum.map(fn {id, timestamp} -> {id, min(timestamp, v2[id])} end)
    |> Enum.into(%{})
  end

  @doc """
  Returns the count of `id` in `v` if it exists. Else it will return 0.
  """
  @spec get(t, any()) :: non_neg_integer()
  def get(v, id) do
    case v[id] do
      nil -> 0
      timestamp -> timestamp
    end
  end

  @doc """
  Increments the count of `id` in `v` by `value`.
  """
  @spec increment(t, any(), non_neg_integer()) :: t
  def increment(v, id, value \\ 1) do
    Map.put(v, id, get(v, id) + value)
  end
end
