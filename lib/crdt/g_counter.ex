defmodule Crdt.GCounter do
  alias Crdt.VectorClock

  def new(), do: VectorClock.new()

  def merge(c1, c2), do: VectorClock.merge(c1, c2)

  def increment(counter, id, value \\ 1), do: VectorClock.increment(counter, id, value)

  def get(counter) do
    counter
    |> Map.values()
    |> Enum.sum()
  end
end
