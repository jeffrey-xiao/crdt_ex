defmodule Crdt.GCounter do
  @moduledoc """
  A G-Counter is a counter that only allows for increments.
  """
  alias Crdt.VectorClock

  @type t :: VectorClock.t

  @doc """
  Returns a new, empty G-Counter.
  """
  @spec new() :: t
  def new(), do: VectorClock.new()

  @doc """
  Merges `c1` and `c2`.
  """
  @spec merge(t, t) :: t
  def merge(c1, c2), do: VectorClock.merge(c1, c2)

  @doc """
  Increments `counter` by `value` using actor `id`.
  """
  @spec increment(t, any(), non_neg_integer()) :: t
  def increment(counter, id, value \\ 1), do: VectorClock.increment(counter, id, value)

  @doc """
  Returns the value of `counter`.
  """
  @spec get(t) :: non_neg_integer()
  def get(counter) do
    counter
    |> Map.values()
    |> Enum.sum()
  end
end
