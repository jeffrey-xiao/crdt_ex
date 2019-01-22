defmodule Crdt.VectorClockTest do
  use ExUnit.Case
  import Crdt.VectorClock
  doctest Crdt.VectorClock

  setup do
    %{
      c1: %{1 => 1, 2 => 2},
      c2: %{2 => 3, 3 => 3},
      c3: %{1 => 1, 2 => 3, 3 => 3}
    }
  end

  test "new" do
    assert new() == %{}
  end

  test "descends?", %{c1: c1, c2: c2, c3: c3} do
    assert descends?(%{}, %{})
    assert descends?(c3, %{})
    assert descends?(c3, c3)
    assert descends?(c3, c1)
    assert descends?(c3, c2)
    refute descends?(c3, %{1 => 2})
  end

  test "dominates?", %{c1: c1, c2: c2, c3: c3} do
    refute dominates?(%{}, %{})
    assert dominates?(c3, %{})
    refute dominates?(c3, c3)
    assert dominates?(c3, c1)
    assert dominates?(c3, c2)
    refute dominates?(c3, %{1 => 2})
  end

  test "concurrent?", %{c1: c1, c2: c2, c3: c3} do
    refute concurrent?(%{}, %{})
    refute concurrent?(c3, %{})
    refute concurrent?(c3, c3)
    refute concurrent?(c3, c1)
    refute concurrent?(c3, c2)
    assert concurrent?(c3, %{1 => 2})
  end

  test "forget", %{c1: c1, c2: c2, c3: c3} do
    assert forget(c1, c3) == %{1 => 1}
    assert forget(c2, c3) == %{2 => 3, 3 => 3}
    assert forget(%{1 => 2, 3 => 1}, c3) == %{1 => 2}
  end

  test "merge", %{c1: c1, c2: c2, c3: c3} do
    assert c3 == merge(c1, c2)
    assert %{1 => 1, 2 => 2, 3 => 3} == merge(%{1 => 1}, %{2 => 2, 3 => 3})
    assert %{1 => 1, 2 => 2, 3 => 3} == merge(%{2 => 2, 3 => 3}, %{1 => 1})
  end

  test "greatest_lower_bound?", %{c1: c1, c2: c2, c3: c3} do
    assert greatest_lower_bound(c1, c3) == c1
    assert greatest_lower_bound(c2, c3) == c2
    assert greatest_lower_bound(%{1 => 2, 3 => 1}, c3) == %{1 => 1, 3 => 1}
  end

  test "get", %{c3: c3} do
    assert get(c3, 1) == 1
    assert get(c3, 2) == 3
    assert get(c3, 3) == 3
  end

  test "increment", %{c3: c3} do
    assert increment(c3, 1) == %{1 => 2, 2 => 3, 3 => 3}
    assert increment(c3, 1, 1) == %{1 => 2, 2 => 3, 3 => 3}
    assert increment(c3, 1, 2) == %{1 => 3, 2 => 3, 3 => 3}
  end

  test "apply", %{c3: c3} do
    assert apply_dot(c3, {2, 2}) == %{1 => 1, 2 => 3, 3 => 3}
    assert apply_dot(c3, {2, 3}) == %{1 => 1, 2 => 3, 3 => 3}
    assert apply_dot(c3, {2, 4}) == %{1 => 1, 2 => 4, 3 => 3}
  end
end
