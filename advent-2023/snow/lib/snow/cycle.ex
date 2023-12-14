defmodule Snow.Cycle do
  @moduledoc """
  [Brent's algorithm](https://en.wikipedia.org/wiki/Cycle%5Fdetection#Brent's_algorithm)
  for cycle detection (Richard P. Brent, that is).
  """

  @doc """
  Find cycles in a sequence defined by the provided function.

  ## Parameters

  - `f`: function that transforms current state to next state
  - `x0`: initial state

  Returns a tuple with these elements:

  - `λ`: cycle length (integer)
  - `μ`: index of first cycle start (integer, 0-relative)
  """
  # credit: code based on Python example in above Wikipedia article
  # TODO allow caller to supply equality function
  def brent(f, x0) do
    # Find cycle length using successive powers of two.
    λ =
      Stream.cycle([true])
      |> Enum.reduce_while({1, 1, x0, f.(x0)}, fn _, {power, λ, tortoise, hare} ->
        cond do
          tortoise == hare ->
            {:halt, λ}
          power == λ ->
            {:cont, {power * 2, 1, hare, f.(hare)}}
          true ->
            {:cont, {power, λ + 1, tortoise, f.(hare)}}
        end
      end)

    # Move the hare λ hops from initial state.
    nth_hare =
      0..(λ - 1)
      |> Enum.reduce(x0, fn _i, hare -> f.(hare) end)

    # With the tortoise starting at the initial state, the hare and tortoise
    # move at same speed until they agree (they will stop at the point where
    # the first cycle begins).
    μ =
      Stream.cycle([true])
      |> Enum.reduce_while({0, x0, nth_hare}, fn _, {μ, tortoise, hare} ->
        if tortoise == hare do
          {:halt, μ}
        else
          {:cont, {μ + 1, f.(tortoise), f.(hare)}}
        end
      end)
 
    # Return λ (cycle length) and μ (index of first cycle start)
    {λ, μ}
  end
end
