defmodule Segment.Decoder do
  @moduledoc """
  Decoding for `Segment`.
  """

  @doc ~S"""
  Comparing digit 1 (2 segments) with digit 7 (3 segments)
  reveals the top segment.

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.top_from_17({ex, []})
      'd'
  """
  def top_from_17({signal_patterns, _output_values}) do
    d1 = Enum.find(signal_patterns, fn p -> length(p) == 2 end)
    d7 = Enum.find(signal_patterns, fn p -> length(p) == 3 end)
    d7 -- d1
  end

  @doc ~S"""
  Digit 4 (4 segments) distinguishes digits 0 6 and 9 (6 segments):
  1. add the top segment to digit 4 (now 5 segments)
  2. digit 9 is the one that adds the bottom segment to it

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.bottom_and_9_from_4069({ex, []})
      {'c', 'abcdef'}
  """
  def bottom_and_9_from_4069({signal_patterns, output_values}) do
    d4 = Enum.find(signal_patterns, fn p -> length(p) == 4 end)
    d4t = d4 ++ top_from_17({signal_patterns, output_values})
    Enum.filter(signal_patterns, fn p -> length(p) == 6 end)
    |> Enum.map(fn d -> {d -- d4t, d} end)
    |> Enum.find(fn {seg, _d} -> Enum.count(seg) == 1 end)
  end

  @doc ~S"""
  Comparing digit 8 (7 segments) with digit 9 (6 segments)
  reveals the lower-left segment.

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.lleft_from_89({ex, []})
      'g'
  """
  def lleft_from_89({signal_patterns, output_values}) do
    d8 = Enum.find(signal_patterns, fn p -> length(p) == 7 end)
    {_, d9} = bottom_and_9_from_4069({signal_patterns, output_values})
    d8 -- d9
  end

  @doc ~S"""
  Digit 7 (3 segments) distinguishes digits 0 6 and 9 (6 segments):
  1. add the bottom and lower-left segments to digit 7 (now 5 segments)
  2. digit 0 is the one that adds the upper-left segment to it

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.uleft_and_0_from_7bll({ex, []})
      {'e', 'abcdeg'}
  """
  def uleft_and_0_from_7bll({signal_patterns, output_values}) do
    d7 = Enum.find(signal_patterns, fn p -> length(p) == 3 end)
    {bottom, _} = bottom_and_9_from_4069({signal_patterns, output_values})
    lleft = lleft_from_89({signal_patterns, output_values})
    d7bll = d7 ++ bottom ++ lleft
    Enum.filter(signal_patterns, fn p -> length(p) == 6 end)
    |> Enum.map(fn d -> {d -- d7bll, d} end)
    |> Enum.find(fn {seg, _d} -> Enum.count(seg) == 1 end)
  end

  @doc ~S"""
  Comparing digit 8 (7 segments) with digit 0 (6 segments)
  reveals the middle segment.

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.middle_from_80({ex, []})
      'f'
  """
  def middle_from_80({signal_patterns, output_values}) do
    d8 = Enum.find(signal_patterns, fn p -> length(p) == 7 end)
    {_, d0} = uleft_and_0_from_7bll({signal_patterns, output_values})
    d8 -- d0
  end

  @doc ~S"""
  Adding middle and bottom segments to digit 7 (3 segments) produces
  digit 3 (5 segments).

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit3_from_7({ex, []})
      'abcdf'
  """
  def digit3_from_7({signal_patterns, output_values}) do
    d7 = Enum.find(signal_patterns, fn p -> length(p) == 3 end)
    middle = middle_from_80({signal_patterns, output_values})
    {bottom, _} = bottom_and_9_from_4069({signal_patterns, output_values})
    d3x = d7 ++ middle ++ bottom
    Enum.filter(signal_patterns, fn p -> length(p) == 5 end)
    |> Enum.map(fn d -> {d -- d3x, d} end)
    |> Enum.find(fn {seg, _d} -> Enum.count(seg) == 0 end)
    |> elem(1)
  end

  @doc ~S"""
  Find digit 6 (6 segments) given the known digits 0 9 (6 segments).

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit6_from_09({ex, []})
      'bcdefg'
  """
  def digit6_from_09({signal_patterns, output_values}) do
    {_, d0} = uleft_and_0_from_7bll({signal_patterns, output_values})
    {_, d9} = bottom_and_9_from_4069({signal_patterns, output_values})
    Enum.filter(signal_patterns, fn p -> length(p) == 6 end)
    |> Enum.find(fn d -> d != d0 && d != d9 end)
  end

  @doc ~S"""
  Removing lower-left segment from digit 6 (6 segments) produces
  digit 5 (5 segments).

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit5_from_6({ex, []})
      'bcdef'
  """
  def digit5_from_6({signal_patterns, output_values}) do
    d6 = digit6_from_09({signal_patterns, output_values})
    lleft = lleft_from_89({signal_patterns, output_values})
    d5x = d6 -- lleft
    Enum.filter(signal_patterns, fn p -> length(p) == 5 end)
    |> Enum.map(fn d -> {d -- d5x, d} end)
    |> Enum.find(fn {seg, _d} -> Enum.count(seg) == 0 end)
    |> elem(1)
  end

  @doc ~S"""
  Find digit 2 (5 segments) given the known digits 3 5 (5 segments).

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit2_from_35({ex, []})
      'acdfg'
  """
  def digit2_from_35({signal_patterns, output_values}) do
    d3 = digit3_from_7({signal_patterns, output_values})
    d5 = digit5_from_6({signal_patterns, output_values})
    Enum.filter(signal_patterns, fn p -> length(p) == 5 end)
    |> Enum.find(fn d -> d != d3 && d != d5 end)
  end

  @doc ~S"""
  Find signal patterns for the 10 digits (in order from 0..9).

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit_signal_patterns({ex, []})
      ['abcdeg', 'ab', 'acdfg', 'abcdf', 'abef', 'bcdef', 'bcdefg', 'abd', 'abcdefg', 'abcdef']
  """
  def digit_signal_patterns({signal_patterns, output_values}) do
    {_, d0} = uleft_and_0_from_7bll({signal_patterns, output_values})
    d1 = Enum.find(signal_patterns, fn p -> length(p) == 2 end)
    d2 = digit2_from_35({signal_patterns, output_values})
    d3 = digit3_from_7({signal_patterns, output_values})
    d4 = Enum.find(signal_patterns, fn p -> length(p) == 4 end)
    d5 = digit5_from_6({signal_patterns, output_values})
    d6 = digit6_from_09({signal_patterns, output_values})
    d7 = Enum.find(signal_patterns, fn p -> length(p) == 3 end)
    d8 = Enum.find(signal_patterns, fn p -> length(p) == 7 end)
    {_, d9} = bottom_and_9_from_4069({signal_patterns, output_values})
    [d0, d1, d2, d3, d4, d5, d6, d7, d8, d9]
  end

  @doc ~S"""
  Translate output values to digits.

  ## Examples
      iex> ex = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> ov = ['bcdef', 'abcdf', 'bcdef', 'abcdf']
      iex> Segment.Decoder.digits_of_note({ex, ov})
      "5353"
  """
  def digits_of_note({signal_patterns, output_values}) do
    indexed_patterns =
      digit_signal_patterns(signal_patterns)
      |> Enum.with_index()
    output_values
    |> Enum.map(fn o -> Enum.find(indexed_patterns, fn {p, _i} -> p == o end) end)
    |> Enum.map(fn t -> elem(t, 1) end)
    |> Enum.map(fn n -> n + ?0 end)
    |> List.to_string()
  end

    #####################
   #######################
  ###                   ###
  ###  REFACTORED CODE  ###
  ###                   ###
   #######################
    #####################

  @doc ~S"""
  Find the signal pattern in `signal_patterns` for the digit with `n` segments.

  ## Examples
      iex> sp = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.find_segments(sp, 3)
      'abd'
      iex> Segment.Decoder.find_segments(sp, 7)
      'abcdefg'
  """
  # TODO RF this can be merged with the `_ne` one (optional `excluding` param)
  def find_segments(signal_patterns, n) do
    Enum.find(signal_patterns, fn p -> length(p) == n end)
  end

  @doc ~S"""
  Find the signal pattern in `signal_patterns` for the digit with `n` segments
  which is NOT in `excluding`.

  ## Examples
      iex> sp = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.find_segments_ne(sp, 5, ['bcdef', 'abcdf'])
      'acdfg'
  """
  def find_segments_ne(signal_patterns, n, excluding) do
    Enum.filter(signal_patterns, fn p -> length(p) == n end)
    |> Enum.find(fn p -> !Enum.member?(excluding, p) end)
  end

  @doc ~S"""
  Merge the segments in signal patterns `da` and `db`.

  ## Examples
      iex> Segment.Decoder.merge_segments('abef', 'abd')
      'abdef'
      iex> Segment.Decoder.merge_segments('bcdef', 'acdfg')
      'abcdefg'
  """
  def merge_segments(da, db) do
    da ++ db
    |> Enum.uniq()
    |> Enum.sort()
  end

  @doc ~S"""
  Find the signal pattern in `signal_patterns` for the digit with `n` segments
  which adds exactly one more segment to the ones in signal pattern `da`
  and which is NOT in `excluding` (if provided).

  ## Examples
      iex> sp = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.find_1_segment_more(sp, 'bcdef', 6, ['abcdef'])
      'bcdefg'
  """
  # TODO RF can calculate `n = length(da) + 1`, don't need to pass it
  def find_1_segment_more(signal_patterns, da, n, excluding \\ []) do
    Enum.filter(signal_patterns, fn p -> length(p) == n end)
    |> Enum.filter(fn p -> !Enum.member?(excluding, p) end)
    |> Enum.map(fn p -> {p -- da, p} end)
    |> Enum.find(fn {seg, _d} -> length(seg) == 1 end)
    |> elem(1)
  end

  @doc ~S"""
  Find signal patterns for the 10 digits (in order from 0..9).

  ## Examples
      iex> sp = ['abcdefg', 'bcdef', 'acdfg', 'abcdf', 'abd', 'abcdef', 'bcdefg', 'abef', 'abcdeg', 'ab']
      iex> Segment.Decoder.digit_signal_patterns(sp)
      ['abcdeg', 'ab', 'acdfg', 'abcdf', 'abef', 'bcdef', 'bcdefg', 'abd', 'abcdefg', 'abcdef']
  """
  def digit_signal_patterns(signal_patterns) do
    # Can determine digits 1, 4, 7, and 8 directly; each one's length is unique in the list:
    #
    d1 = find_segments(signal_patterns, 2)
    d4 = find_segments(signal_patterns, 4)
    d7 = find_segments(signal_patterns, 3)
    d8 = find_segments(signal_patterns, 7)

    # Can determine digit 9 by merging the segments of digits 4 and 7, and then finding the digit that adds exactly one segment to that (the bottom one):
    #
    d47 = merge_segments(d4, d7)
    d9 = find_1_segment_more(signal_patterns, d47, 6)

    # Can determine digit 5 by subtracting digit 1's segments from digit 9's (the right two), and then finding the digit that adds exactly one segment to that (the lower-right one):
    #
    d9m1 = d9 -- d1
    d5 = find_1_segment_more(signal_patterns, d9m1, 5)

    # Can determine digit 6 by finding the 6-segment digit that adds one segment to digit 5, and isn't digit 9:
    #
    d6 = find_1_segment_more(signal_patterns, d5, 6, [d9])

    # Can determine digit 0 by finding the 6-segment digit that isn't 6 or 9:
    #
    d0 = find_segments_ne(signal_patterns, 6, [d6, d9])

    # Can determine and distinguish digits 2 and 3: Only the segments from 2 + 5 yield 8, and 3 is the other one.
    #
    d2or3 = find_segments_ne(signal_patterns, 5, [d5])
    d3or2 = find_segments_ne(signal_patterns, 5, [d5, d2or3])
    {d2, d3} =
      if merge_segments(d2or3, d5) == d8 do
        {d2or3, d3or2}
      else
        {d3or2, d2or3}
      end

    [d0, d1, d2, d3, d4, d5, d6, d7, d8, d9]
  end
end
