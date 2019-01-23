defmodule Crdt.ORSet do
  @moduledoc """
  An OR-Set Without Tombstones (ORSWOT) allows for insertions and removals of elements. Should an
  insertion and removal be concurrent, the insertion wins.
  """
  defstruct clock: %{}, entries: %{}, deferred: %{}

  alias Crdt.VectorClock

  @type t :: %__MODULE__{
          clock: VectorClock.t(),
          entries: %{any() => any()},
          deferred: %{any() => any()}
        }

  @doc """
  Returns a new, empty OR-Set Without Tombstones.
  """
  @spec new() :: t
  def new(), do: %__MODULE__{clock: VectorClock.new(), entries: %{}, deferred: %{}}

  @doc """
  Merges `s1` and `s2`.
  """
  @spec merge(t, t) :: t
  def merge(s1, s2) do
    clock = VectorClock.merge(s1.clock, s2.clock)

    {keep, entries2} =
      Enum.reduce(s1.entries, {%{}, s2.entries}, fn {item, clock1}, {keep, entries2} ->
        case s2.entries[item] do
          nil ->
            # `s2` removed item after `s1` added item.
            if VectorClock.descends?(s2.clock, clock1) do
              {keep, entries2}
              # `s2` has not yet witnessed insertion.
            else
              {Map.put(keep, item, clock1), entries2}
            end

          clock2 ->
            common_clock = VectorClock.intersection(s1.clock, s2.clock)

            clock1 =
              clock1
              |> VectorClock.forget(common_clock)
              |> VectorClock.forget(s2.clock)

            clock2 =
              clock2
              |> VectorClock.forget(common_clock)
              |> VectorClock.forget(s1.clock)

            common_clock =
              common_clock
              |> VectorClock.merge(clock1)
              |> VectorClock.merge(clock2)

            if common_clock == %{} do
              {keep, Map.delete(entries2, item)}
            else
              {Map.put(keep, item, common_clock), Map.delete(entries2, item)}
            end
        end
      end)

    keep =
      Enum.reduce(entries2, keep, fn {item, clock2}, keep ->
        clock2 = VectorClock.forget(clock2, s1.clock)

        if clock2 == %{} do
          keep
        else
          Map.put(keep, item, clock2)
        end
      end)

    deferred =
      Map.merge(s1.deferred, s2.deferred, fn _clock, items1, items2 ->
        MapSet.union(items1, items2)
      end)

    %__MODULE__{clock: clock, entries: keep, deferred: deferred}
    |> apply_deferred_remove()
  end

  @doc """
  Adds `item` to `set` using actor `id`..
  """
  @spec add(t, any(), any()) :: t
  def add(set, item, id) do
    apply_add(set, item, {id, VectorClock.get(set.clock, id) + 1})
  end

  @doc """
  Applies an add operation to `set` using `item` and with `dot` as the birth dot.
  """
  @spec apply_add(t, any(), {any(), non_neg_integer()}) :: t
  def apply_add(set, item, dot) do
    clock = VectorClock.apply_dot(set.clock, dot)

    # Apply birth dot to entries.
    entries =
      Map.update(set.entries, item, VectorClock.new() |> VectorClock.apply_dot(dot), fn clock ->
        VectorClock.apply_dot(clock, dot)
      end)

    # Try to apply all deferred entries.
    %__MODULE__{set | entries: entries, clock: clock}
    |> apply_deferred_remove()
  end

  @doc """
  Removes `item` from `set`.
  """
  @spec remove(t, any()) :: t
  def remove(set, item) do
    apply_remove(set, item, set.clock)
  end

  @doc """
  Applies a remove operation to `set` using `item` and with `clock` as the underlying causal
  context.
  """
  @spec apply_remove(t, any(), VectorClock.t()) :: t
  def apply_remove(set, item, clock) do
    # Have not yet seen remove operation, so add to deferred items.
    set =
      if !VectorClock.descends?(set.clock, clock) do
        deferred =
          Map.update(set.deferred, clock, MapSet.new([item]), fn deferred_items ->
            MapSet.put(deferred_items, item)
          end)

        %__MODULE__{set | deferred: deferred}
      else
        set
      end

    case Map.pop(set.entries, item) do
      {nil, _entries} ->
        set

      {entry_clock, entries} ->
        entry_clock = VectorClock.forget(entry_clock, clock)

        # Remove item if the remove clock descends the birth clock, otherwise update the birth
        # clock.
        entries =
          if entry_clock != %{} do
            Map.put(entries, item, entry_clock)
          else
            entries
          end

        %__MODULE__{set | entries: entries}
    end
  end

  defp apply_deferred_remove(set) do
    deferred = set.deferred

    # Attempt to remove all deferred entries.
    Enum.reduce(deferred, %__MODULE__{set | deferred: %{}}, fn {clock, items}, acc ->
      Enum.reduce(items, acc, fn item, acc ->
        apply_remove(acc, item, clock)
      end)
    end)
  end

  @doc """
  Returns all items in `set`.
  """
  @spec get(t) :: MapSet.t(any())
  def get(set) do
    set.entries |> Map.keys() |> MapSet.new()
  end

  @doc """
  Returns `true` if `item` is a member of `set`.
  """
  @spec member?(t, any()) :: boolean()
  def member?(set, item) do
    Map.has_key?(set.entries, item)
  end
end
