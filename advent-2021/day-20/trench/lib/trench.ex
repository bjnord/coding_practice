defmodule Trench do
  @moduledoc """
  Documentation for Trench.
  """

  alias Trench.Image, as: Image
  alias Trench.Parser, as: Parser
  import Submarine.CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
    if opts[:visualize], do: visualize(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    # "Start with the original input image and apply the image enhancement
    # algorithm twice [...]. How many pixels are lit in the resulting image?"
    {algor, {radius, pixmap}} =
      File.read!(input_file)
      |> Parser.parse()
    {radius, pixmap}
    |> Image.new()
    |> Image.apply(algor)
    |> Image.apply(algor)
    |> Image.lit_count()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    # "Start again with the original input image and apply the image
    # enhancement algorithm 50 times. How many pixels are lit in the
    # resulting image?"
    {algor, {radius, pixmap}} =
      File.read!(input_file)
      |> Parser.parse()
    image = Image.new({radius, pixmap})
    1..50
    |> Enum.reduce(image, fn (_n, enh_image) ->
      Image.apply(enh_image, algor)
    end)
    |> Image.lit_count()
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Process input file and produce visualization of part 2 solution.
  """
  def visualize(input_file) do
    {algor, {radius, pixmap}} =
      File.read!(input_file)
      |> Parser.parse()
    image = Image.new({radius, pixmap})
    viz_dim = 220
    Image.visualize(image, viz_dim, 0)
    1..50
    |> Enum.reduce(image, fn (n, enh_image) ->
      enh_image = Image.apply(enh_image, algor)
      Image.visualize(enh_image, viz_dim, n)
      enh_image
    end)
  end
end
