defmodule Crdt.LWWSetTest do
  use ExUnit.Case
  import Crdt.LWWSet
  alias Crdt.LWWSet
  doctest Crdt.LWWSet

  test "new" do
    assert new(:remove) == %LWWSet{a_map: %{}, r_map: %{}, bias: :remove}
  end

  test "add and remove" do
    set = new(:add) |> add(1, 1)
    assert member?(set, 1)

    set = new(:add) |> add(1, 2) |> remove(1, 1)
    assert member?(set, 1)

    set = new(:add) |> add(1, 1) |> remove(1, 2)
    refute member?(set, 1)

    set = new(:remove) |> add(1, 1) |> remove(1, 1)
    refute member?(set, 1)

    set = new(:add) |> add(1, 1) |> remove(1, 1)
    assert member?(set, 1)
  end

  test "merge" do
    s1 = new(:add) |> add(1, 2) |> add(2, 1) |> add(3, 1) |> remove(1, 1) |> remove(2, 2)
    s2 = new(:add) |> add(1, 1) |> add(2, 3) |> add(4, 1) |> remove(1, 3) |> remove(2, 1)
    s3 = merge(s1, s2)

    assert_raise RuntimeError, fn -> merge(new(:add), new(:remove)) end
    refute member?(s3, 1)
    assert member?(s3, 2)
    assert member?(s3, 3)
    assert member?(s3, 4)
  end
end
