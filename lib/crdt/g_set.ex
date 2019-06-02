defmodule Crdt.GSet do
  @moduledoc """
  A G-Set is a set where elements can only be added.
  """

  @type t :: MapSet.t(any())

  @doc """
  Returns a new, empty G-Set.
  """
  @spec new :: t()
  def new, do: MapSet.new()

  @doc """
  Merges `s1` and `s2`.
  """
  @spec merge(t(), t()) :: t()
  def merge(s1, s2), do: MapSet.union(s1, s2)

  @doc """
  Adds `item` to `set`.
  """
  @spec add(t(), any()) :: t()
  def add(set, item), do: MapSet.put(set, item)

  @doc """
  Returns all items in `set`.
  """
  @spec get(t()) :: MapSet.t(any())
  def get(set), do: set

  @doc """
  Returns `true` is `item` is a member of `set`.
  """
  @spec member?(t(), any()) :: boolean()
  def member?(set, item), do: MapSet.member?(set, item)
end
