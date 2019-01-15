defmodule Crdt.GCounter do
  defstruct clock: %{}

  alias Crdt.VectorClock

  def new(), do: %__MODULE__{clock: VectorClock.new()}

  def merge(c1, c2), do: %__MODULE__{clock: VectorClock.merge(c1.clock, c2.clock)}

  def increment(counter, id, value \\ 1),
    do: %{counter | clock: VectorClock.increment(counter.clock, id, value)}

  def get(counter) do
    counter.clock
    |> Map.values()
    |> Enum.sum()
  end
end
