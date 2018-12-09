defmodule ElfTasksTest do
  use ExUnit.Case
  doctest ElfTasks

  import ElfTasks

  test "new() creates new map" do
    assert new(1) == %{1 => nil}
    assert new(3) == %{1 => nil, 2 => nil, 3 => nil}
  end

  test "new() raises exception if invalid arg" do
    assert_raise ArgumentError, fn -> new(0) end
  end

  test "free_elf?()" do
    assert free_elf?(%{1 => nil, 2 => nil}) == true
    assert free_elf?(%{1 => {"A", 1}, 2 => nil}) == true
    assert free_elf?(%{1 => {"A", 1}, 2 => {"B", 2}}) == false
  end

  test "assign_task() assigns a task" do
    assert assign_task(%{1 => {"A", 1}, 2 => nil}, {"C", 3}) == %{1 => {"A", 1}, 2 => {"C", 3}}
  end

  test "assign_task() raises exception if invalid duration" do
    assert_raise ArgumentError, fn -> assign_task(%{1 => {"A", 1}, 2 => nil}, {"C", 0}) end
  end

  test "assign_task() raises exception if no elves free" do
    assert_raise ElfTasksError, fn -> assign_task(%{1 => {"A", 1}, 2 => {"B", 2}}, {"C", 3}) end
  end

  test "soonest_task()" do
    assert soonest_task(%{1 => nil, 2 => nil}) == {nil, nil, nil}
    assert soonest_task(%{1 => {"C", 3}, 2 => {"A", 1}, 3 => {"B", 2}}) == {2, "A", 1}
    assert soonest_task(%{1 => {"B", 0}, 2 => nil, 3 => nil}) == {1, "B", 0}
  end

  test "complete_task() completes a task and simulates time" do
    assert complete_task(%{3 => {"A", 1}, 1 => {"B", 5}, 2 => {"C", 6}}, 3) == %{1 => {"B", 4}, 2 => {"C", 5}, 3 => nil}
    assert complete_task(%{3 => {"A", 1}, 1 => {"B", 2}, 2 => nil}, 3) == %{1 => {"B", 1}, 2 => nil, 3 => nil}
    assert complete_task(%{3 => {"A", 1}, 1 => {"B", 1}, 2 => nil}, 3) == %{1 => {"B", 0}, 2 => nil, 3 => nil}
  end

  test "complete_task() raises exception if elf has no task" do
    assert_raise ElfTasksError, fn -> complete_task(%{1 => {"A", 1}, 2 => nil}, 2) end
  end

  test "complete_task() raises exception if other task completes sooner" do
    assert_raise ElfTasksError, fn -> complete_task(%{1 => {"B", 2}, 2 => {"C", 3}}, 2) end
  end
end
