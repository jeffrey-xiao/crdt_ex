defmodule Crdt.ORSet do
  @moduledoc """
  An OR-Set Without Tombstones (ORSWOT) allows for insertions and removals of elements. Should an
  insertion and removal be concurrent, the insertion wins.
  """
  defstruct clock: %{}, entries: %{}, deferred: %{}

  alias Crdt.VectorClock

  def new(), do: %__MODULE__{clock: VectorClock.new(), entries: %{}, deferred: %{}}

  def merge(s1, s2) do
    clock = VectorClock.merge(s1.clock, s2.clock)

    {keep, entries2} =
      Enum.reduce(s1.entries, {%{}, s2.entries}, fn {item, clock1}, {acc, entries2} ->
        case s2.entries[item] do
          nil ->
            if VectorClock.descends?(s2.clock, clock1) do
              {acc, entries2}
            else
              {Map.put(acc, item, clock1), entries2}
            end

          clock2 ->
            nil
        end
      end)
  end

  def add(set, item, id) do
    clock = VectorClock.increment(set.clock, id)
    dot = {id, VectorClock.get(clock, id)}

    # Apply birth dot to entries.
    entries =
      Map.update(set.entries, item, VectorClock.new() |> VectorClock.apply_dot(dot), fn clock ->
        VectorClock.apply_dot(clock, dot)
      end)

    # Try to apply all deferred entries.
    %__MODULE__{set | entries: entries, clock: clock}
    |> apply_deferred_remove()
  end

  def remove(set, item) do
    apply_remove(set, item, set.clock)
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

  defp apply_remove(set, item, clock) do
    # Have not yet seen remove operation, so add to deferred items.
    if !VectorClock.descends?(set.clock, clock) do
      deferred =
        Map.update(set.deferred, clock, MapSet.new([item]), fn deferred_items ->
          MapSet.put(deferred_items, item)
        end)

      %__MODULE__{set | deferred: deferred}
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

  def get(set) do
    set.entries |> Map.keys()
  end

  def member?(set, item) do
    Map.has_key?(set.entries, item)
  end
end
