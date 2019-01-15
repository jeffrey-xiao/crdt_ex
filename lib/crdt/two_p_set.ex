defmodule Crdt.TwoPSet do
  defstruct a_set: %{}, r_set: %{}

  alias Crdt.GSet

  def new(), do: %__MODULE__{a_set: GSet.new(), r_set: GSet.new()}

  def merge(s1, s2),
    do: %__MODULE__{
      a_set: GSet.merge(s1.a_set, s2.a_set),
      r_set: GSet.merge(s1.r_set, s2.r_set)
    }

  def add(set, item), do: %__MODULE__{set | a_set: GSet.add(set.a_set, item)}

  def remove(set, item) do
    if GSet.member?(set.a_set, item) do
      %__MODULE__{set | r_set: GSet.add(set.r_set, item)}
    else
      set
    end
  end

  def member?(set, item) do
    GSet.member?(set.a_set, item) && !GSet.member?(set.r_set, item)
  end
end
