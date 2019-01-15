defmodule Crdt.GSet do
  defstruct items: %{}

  alias Crdt.VectorClock

  def new(), do: %__MODULE__{items: MapSet.new()}

  def merge(s1, s2), do: %__MODULE__{items: MapSet.union(s1, s2)}

  def add(set, item), do: %{set | items: MapSet.put(set.items, item)}

  def member?(set, item), do: Map.member?(set, item)
end
