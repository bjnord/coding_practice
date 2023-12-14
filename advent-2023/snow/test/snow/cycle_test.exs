defmodule Snow.CycleTest do
  use ExUnit.Case
  doctest Snow.Cycle

  alias Snow.Cycle

  test "Brent's algorithm: pure cycle, no extra initial values" do
    λ = 8
    next_f = fn x -> rem(x + 1, λ) end
    assert Cycle.brent(next_f, 0) == {λ, 0}
  end

  test "Brent's algorithm: cycle with 1 extra initial value" do
    λ = 8
    next_f = fn x -> rem(x + 1, λ) end
    assert Cycle.brent(next_f, -1) == {λ, 1}
  end
end
