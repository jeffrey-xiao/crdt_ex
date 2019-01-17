defmodule Crdt.GCounter do
  @moduledoc """
  A G-Counter is a counter that only allows for increments.
  """
  alias Crdt.VectorClock

  @doc """
  Returns a new, empty G-Counter.
  """
  def new(), do: VectorClock.new()

  @doc """
  Merges `c1` and `c2`.
  """
  def merge(c1, c2), do: VectorClock.merge(c1, c2)

  @doc """
  Increments `counter` by `value` using actor `id`.
  """
  def increment(counter, id, value \\ 1), do: VectorClock.increment(counter, id, value)

  @doc """
  Returns the value of `counter`.
  """
  def get(counter) do
    counter
    |> Map.values()
    |> Enum.sum()
  end
end
