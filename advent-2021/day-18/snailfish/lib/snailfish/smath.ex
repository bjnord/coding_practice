defmodule Snailfish.Smath do
  @moduledoc """
  Math for `Snailfish`.
  """

  alias Snailfish.Parser, as: Parser

  @doc ~S"""
  Add snailfish numbers.

  ## Examples
      iex> Snailfish.Smath.add(["[1,2]", "[[3,4],5]"])
      "[[1,2],[[3,4],5]]"
  """
  def add([n]), do: n
  def add([n1, n2]) do
    "[#{n1},#{n2}]"
    |> reduce()
  end
  def add([n1 | [n2 | numbers]]), do: add([add([n1, n2]) | numbers])

  # Reduce snailfish number (in tokenized form).
  #
  # "During reduction, at most one action applies, after which the process
  # returns to the top of the list of actions. For example, if split produces
  # a pair that meets the explode criteria, that pair explodes before other
  # splits occur." (_BJN: I think this just means: If number has a splittable
  # and an explodable, do the explode first._)
  #
  defp reduce(number) when is_binary(number) do
    Parser.to_tokens(number)
    |> reduce()
  end
  defp reduce(tokens) when is_list(tokens) do
    i = find_splittable_index(tokens)
    c = find_explodable_context(tokens)
    cond do
      # explode, and continue reducing
      c != nil -> reduce(explode_at(tokens, c))
      # split, and continue reducing
      i != nil -> reduce(split_at(tokens, i))
      # no further reduction needed
      {nil, nil} -> Parser.to_string(tokens)
    end
  end

  # Return index in `tokens` of leftmost splittable integer, or `nil` if none.
  #
  # "If any regular number is 10 or greater, the leftmost such regular number splits."
  #
  defp find_splittable_index(tokens) when is_list(tokens) do
    Enum.find_index(tokens, &(splittable(&1)))
  end

  defp splittable(token) when is_integer(token) and token >= 10, do: true
  defp splittable(_token), do: false

  # Split integer at `index` in `tokens`. Returns new `tokens`.
  #
  # "To split a regular number, replace it with a pair; the left element of
  # the pair should be the regular number divided by two and rounded down,
  # while the right element of the pair should be the regular number divided
  # by two and rounded up."
  #
  defp split_at(tokens, i) when is_list(tokens) do
    {head, [n | tail]} = Enum.split(tokens, i)
    n1 = div(n, 2)
    n2 = n - n1
    sn = [:o, n1, :s, n2, :c]
    # TODO OPTIMIZE this is really inefficient:
    head ++ sn ++ tail
  end

  # Return context of leftmost explodable pair in `tokens`, or `nil` if none.
  # A context is a tuple containing the following indexes in `tokens`:
  # - index of the open-brace of the explodable pair
  # - index of the preceding integer (or `nil` if none)
  # - index of the following integer (or `nil` if none)
  #
  # "If any pair is nested inside four pairs, the leftmost such pair explodes."
  #
  @doc false
  def find_explodable_context(tokens) when is_list(tokens) do
    Enum.with_index(tokens)
    |> find_context(0, nil)
  end

  defp find_context([], level, _prev_i) when level > 0,
    do: raise ArgumentError, "too many open braces"
  defp find_context([], _level, _prev_i), do: nil
  defp find_context([{tok, i} | tail], level, prev_i) do
    if level < 0 do
      raise ArgumentError, "too many close braces"
    end
    prev_i = update_prev_i(tok, i, prev_i)
    cond do
      level >= 4 and simple_pair?([{tok, i} | tail]) ->
        {i, prev_i, next_i([{tok, i} | tail], i)}
      true ->
        find_context(tail, adjust_level(tok, level), prev_i)
    end
  end

  defp next_i(itokens, i) do
    {_pair, itokens} = Enum.split(itokens, 5)
    case Enum.find_index(itokens, &integer_itoken?/1) do
      nil -> nil
      rel_i -> i + 5 + rel_i
    end
  end

  defp integer_itoken?({tok, _i}) when is_integer(tok), do: true
  defp integer_itoken?({_tok, _i}), do: false

  # BEHOLD THE POWER OF ELIXIR MATCHING!
  defp simple_pair?([{:o, _}, {n1, _}, {:s, _}, {n2, _}, {:c, _} | _tail])
    when is_integer(n1) and is_integer(n2),
    do: true
  defp simple_pair?(_itokens), do: false

  defp update_prev_i(tok, i, _prev_i) when is_integer(tok), do: i
  defp update_prev_i(_tok, _i, prev_i), do: prev_i

  defp adjust_level(tok, level) do
    case tok do
      :o -> level + 1
      :c -> level - 1
      _ -> level
    end
  end

  # Explode pair in the given context in `tokens`. Returns new `tokens`.
  #
  # "To explode a pair, the pair's left value is added to the first regular
  # number to the left of the exploding pair (if any), and the pair's
  # right value is added to the first regular number to the right of the
  # exploding pair (if any). Exploding pairs will always consist of two
  # regular numbers. Then, the entire exploding pair is replaced with the
  # regular number 0."
  #
  # NB `prev_i == nil and next_i == nil` can't happen
  #
  @doc false
  def explode_at(tokens, {i, prev_i, next_i}) when is_list(tokens) and prev_i == nil do
    ###
    # break tokens into segments
    {head, tail} = Enum.split(tokens, i)
    {[:o, _lval, :s, rval, :c], tail} = Enum.split(tail, 5)
    {middle, tail} = Enum.split(tail, next_i - i - 5)
    [next | tail] = tail
    ###
    # do the explode
    next = next + rval
    ###
    # reassemble the modified segments
    # TODO OPTIMIZE this is really inefficient:
    head ++ [0] ++ middle ++ [next] ++ tail
  end
  def explode_at(tokens, {i, prev_i, next_i}) when is_list(tokens) and next_i == nil do
    ###
    # break tokens into segments
    {head, tail} = Enum.split(tokens, prev_i)
    [prev | tail] = tail
    {middle, tail} = Enum.split(tail, i - prev_i - 1)
    {[:o, lval, :s, _rval, :c], tail} = Enum.split(tail, 5)
    ###
    # do the explode
    prev = prev + lval
    ###
    # reassemble the modified segments
    # TODO OPTIMIZE this is really inefficient:
    head ++ [prev] ++ middle ++ [0] ++ tail
  end
  def explode_at(tokens, {i, prev_i, next_i}) when is_list(tokens) do
    ###
    # break tokens into segments
    {head, tail} = Enum.split(tokens, prev_i)
    [prev | tail] = tail
    {lmiddle, tail} = Enum.split(tail, i - prev_i - 1)
    {[:o, lval, :s, rval, :c], tail} = Enum.split(tail, 5)
    {rmiddle, tail} = Enum.split(tail, next_i - i - 5)
    [next | tail] = tail
    ###
    # do the explode
    prev = prev + lval
    next = next + rval
    ###
    # reassemble the modified segments
    # TODO OPTIMIZE this is really inefficient:
    head ++ [prev] ++ lmiddle ++ [0] ++ rmiddle ++ [next] ++ tail
  end

  @doc ~S"""
  Compute magnitude of snailfish number.

  ## Examples
      iex> Snailfish.Smath.magnitude("[9,1]")
      29
      iex> Snailfish.Smath.magnitude("[[9,1],[1,9]]")
      129
  """
  # "The magnitude of a pair is 3 times the magnitude of its left element
  # plus 2 times the magnitude of its right element. The magnitude of a
  # regular number is just that number. [...] Magnitude calculations are
  # recursive"
  #
  # TODO OPTIMIZE can this be made tail-recursive?
  def magnitude(number) when is_binary(number) do
    Regex.run(~r/^(.*)\[(\d+),(\d+)\](.*)$/, number)
    |> mag_replace(number)
  end

  defp mag_replace([_, front, l, r, back], _original) do
    mag = String.to_integer(l) * 3 + String.to_integer(r) * 2
    magnitude("#{front}#{mag}#{back}")
  end
  defp mag_replace(_, original), do: String.to_integer(original)

  @doc """
  Find largest magnitude of the sums of all combinations of two (different)
  snailfish numbers.
  """
  def largest_magnitude(numbers) do
    hw_nums = List.to_tuple(numbers)
    nn = tuple_size(hw_nums)
    for n1 <- 0..nn-1, n2 <- 0..nn-1 do
      cond do
        n1 == n2 ->
          0
        true ->
          add([elem(hw_nums, n1), elem(hw_nums, n2)])
          |> magnitude()
      end
    end
    |> Enum.max()
  end
end
