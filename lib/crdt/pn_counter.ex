defmodule Crdt.PNCounter do
  defstruct p_clock: %{}, n_clock: %{}

  alias Crdt.VectorClock

  def new(), do: %__MODULE__{p_clock: VectorClock.new()}

  def merge(c1, c2),
    do: %__MODULE__{
      p_clock: VectorClock.merge(c1.p_clock, c2.p_clock),
      n_clock: VectorClock.merge(c1.n_clock, c2.n_clock)
    }

  def increment(counter, id, value \\ 1),
    do: %{counter | p_clock: VectorClock.increment(counter.clock, id, value)}

  def decrement(counter, id, value \\ 1),
    do: %{counter | n_clock: VectorClock.increment(counter.clock, id, value)}

  def get(counter) do
    p_count =
      counter.p_clock
      |> Map.values()
      |> Enum.sum()

    n_count =
      counter.n_clock
      |> Map.values()
      |> Enum.sum()

    p_count - n_count
  end
end