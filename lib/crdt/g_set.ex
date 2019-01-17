defmodule Crdt.GSet do
  def new(), do: MapSet.new()

  def merge(s1, s2), do: MapSet.union(s1, s2)

  def add(set, item), do: MapSet.put(set, item)

  def member?(set, item), do: MapSet.member?(set, item)
end
