defmodule Crdt.GSet do
  @moduledoc """
  A G-Set is a set where elements can only be added.
  """
  def new(), do: MapSet.new()

  @doc """
  Merges `s1` and `s2`.
  """
  def merge(s1, s2), do: MapSet.union(s1, s2)

  @doc """
  Adds `item` to `set`.
  """
  def add(set, item), do: MapSet.put(set, item)

  @doc """
  Returns `true` is `item` is a member of `set`.
  """
  def member?(set, item), do: MapSet.member?(set, item)
end
