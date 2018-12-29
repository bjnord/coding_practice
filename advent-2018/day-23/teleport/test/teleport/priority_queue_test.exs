defmodule Teleport.PriorityQueueTest do
  use ExUnit.Case
  doctest Teleport.PriorityQueue

  import Teleport.PriorityQueue

  test "pop & count" do
    primes = new([{2, :two}, {3, :three}])
    assert count(primes) == 2
    primes_t = new([{3, :three}])
    {updated_primes, top_entry} = pop(primes)
    assert updated_primes == primes_t
    assert top_entry == {2, :two}
    assert count(updated_primes) == 1
  end

  test "pop (empty)" do
    primes = new([])
    {updated_primes, top_entry} = pop(primes)
    assert top_entry == nil
    assert count(updated_primes) == 0
  end

  test "keys" do
    primes = new([{2, :two}, {3, :three}, {5, :five}])
    assert keys(primes) == [2, 3, 5]
  end

  test "ordered insertion (empty queue)" do
    primes = new([])
    composites = [{8, :eight}, {4, :four}]
    assert add(primes, composites) |> keys() == [4, 8]
  end

  test "ordered insertion (empty insertion)" do
    primes = new([{2, :two}, {3, :three}])
    composites = []
    assert add(primes, composites) |> keys() == [2, 3]
  end

  test "ordered insertion (bigger example)" do
    primes = new([
      {2, :two},
      {3, :three},
      {5, :five},
      {7, :seven},
      {11, :eleven},
      {13, :thirteen},
      {17, :seventeen},
      {19, :nineteen},
      {23, :twenty_three},
      {29, :twenty_nine},
    ])
    composites = [
      {24, :twenty_four},
      {8, :eight},
      {20, :twenty},
      {4, :four},
      {16, :sixteen},
      {28, :twenty_eight},
      {12, :twelve},
    ]
    result = [2, 3, 4, 5, 7, 8, 11, 12, 13, 16, 17, 19, 20, 23, 24, 28, 29]
    assert add(primes, composites) |> keys() == result
  end
end
