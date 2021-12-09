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
      digit_signal_patterns({signal_patterns, output_values})
      |> Enum.with_index()
    output_values
    |> Enum.map(fn o -> Enum.find(indexed_patterns, fn {p, _i} -> p == o end) end)
    |> Enum.map(fn t -> elem(t, 1) end)
    |> Enum.map(fn n -> n + ?0 end)
    |> List.to_string()
  end
end
