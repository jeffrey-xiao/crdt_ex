defmodule Crdt.TwoPSet do
  @moduledoc """
  A 2P-Set consists of two G-Sets and allows for an element to be added and removed at most once.
  """
  defstruct a_set: %{}, r_set: %{}

  alias Crdt.GSet

  @type t :: %__MODULE__{a_set: GSet.t(), r_set: GSet.t()}

  @doc """
  Returns a new, empty 2P-Set.
  """
  @spec new :: t()
  def new, do: %__MODULE__{a_set: GSet.new(), r_set: GSet.new()}

  @doc """
  Merges `s1` and `s2`.
  """
  @spec merge(t(), t()) :: t()
  def merge(s1, s2),
    do: %__MODULE__{
      a_set: GSet.merge(s1.a_set, s2.a_set),
      r_set: GSet.merge(s1.r_set, s2.r_set)
    }

  @doc """
  Adds `item` to `set`.
  """
  @spec add(t(), any()) :: t()
  def add(set, item), do: %__MODULE__{set | a_set: GSet.add(set.a_set, item)}

  @doc """
  Removes `item` from `set.
  """
  @spec remove(t(), any()) :: t()
  def remove(set, item) do
    if GSet.member?(set.a_set, item) do
      %__MODULE__{set | r_set: GSet.add(set.r_set, item)}
    else
      set
    end
  end

  @doc """
  Returns all items in `set`.
  """
  @spec get(t()) :: MapSet.t(any())
  def get(set), do: MapSet.difference(GSet.get(set.a_set), GSet.get(set.r_set))

  @doc """
  Returns `true` if `item` is a member of `set`.
  """
  @spec member?(t(), any()) :: boolean()
  def member?(set, item) do
    GSet.member?(set.a_set, item) && !GSet.member?(set.r_set, item)
  end
end
