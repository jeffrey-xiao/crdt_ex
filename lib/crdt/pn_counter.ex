defmodule Crdt.PNCounter do
  @moduledoc """
  A PN-Counter consists of two G-Counters and allows for increments and decrements.
  """
  defstruct p_clock: %{}, n_clock: %{}

  alias Crdt.VectorClock

  @doc """
  Returns a new, empty PN-Counter.
  """
  def new(), do: %__MODULE__{p_clock: VectorClock.new(), n_clock: VectorClock.new()}

  @doc """
  Merges `c1` and `c2`.
  """
  def merge(c1, c2),
    do: %__MODULE__{
      p_clock: VectorClock.merge(c1.p_clock, c2.p_clock),
      n_clock: VectorClock.merge(c1.n_clock, c2.n_clock)
    }

  @doc """
  Increments `counter` by `value` using actor `id`.
  """
  def increment(counter, id, value \\ 1),
    do: %{counter | p_clock: VectorClock.increment(counter.p_clock, id, value)}

  @doc """
  Decrements `counter` by `value` using actor `id`.
  """
  def decrement(counter, id, value \\ 1),
    do: %{counter | n_clock: VectorClock.increment(counter.n_clock, id, value)}

  @doc """
  Returns the value of `counter`.
  """
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
