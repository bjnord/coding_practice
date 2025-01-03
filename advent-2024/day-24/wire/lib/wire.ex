defmodule Wire do
  @moduledoc """
  Documentation for `Wire`.
  """

  import Bitwise
  import History.CLI
  require Logger
  alias Wire.Dumper
  import Wire.Parser

  def eval(diagram) do
    Map.keys(diagram)
    |> Enum.filter(&z_wire?/1)
    |> build_queue(diagram)
    |> then(fn queue -> {%{}, queue} end)
    |> eval_queue(diagram)
    |> reduce_value()
  end

  defp build_queue(z_wires, diagram) do
    z_wires
    |> Enum.reduce([], fn z_wire, queue ->
      add_to_queue(queue, z_wire, diagram)
    end)
  end

  defp add_to_queue(queue, wire = rhs, diagram) when is_binary(rhs) do
    rhs = Map.get(diagram, wire)
    add_to_queue([wire | queue], rhs, diagram)
  end
  defp add_to_queue(queue, {wire1, _gate, wire2} = _rhs, diagram) do
    add_to_queue(queue, wire1, diagram)
    |> add_to_queue(wire2, diagram)
  end
  defp add_to_queue(queue, _rhs, _diagram), do: queue

  defp eval_queue({values, []}, _diagram), do: values
  defp eval_queue({values, [item | queue]}, diagram) do
    value = eval_item(values, Map.get(diagram, item))
    next = {Map.put(values, item, value), queue}
    eval_queue(next, diagram)
  end

  defp eval_item(values, wire = rhs) when is_atom(rhs) do
    Map.get(values, wire)
  end
  defp eval_item(values, {wire1, gate, wire2} = _rhs) do
    value1 = Map.get(values, wire1)
    value2 = Map.get(values, wire2)
    expr(value1, gate, value2)
  end
  defp eval_item(_values, value = _rhs), do: value

  defp expr(v1, :AND, v2), do: v1 &&& v2
  defp expr(v1, :OR, v2), do: v1 ||| v2
  defp expr(v1, :XOR, v2), do: bxor(v1, v2)

  def reduce_value(values) do
    Map.keys(values)
    |> Enum.filter(&z_wire?/1)
    |> Enum.sort(&(&1 >= &2))
    |> Enum.reduce(0, fn wire, acc ->
      acc * 2 + Map.get(values, wire)
    end)
  end

  def swapped_wires(diagram) do
    swap_list(diagram)
    |> Enum.map(fn {w1, w2} -> [w1, w2] end)
    |> List.flatten()
    |> Enum.sort
  end

  # TODO find these algorithmically :)
  #      (I did it by diff'ing the puzzle input with a generated adder)
  def swap_list(_diagram) do
    [
      {"z10", "vcf"},
      {"fhg", "z17"},
      {"dvb", "fsq"},
      {"tnc", "z39"}
    ]
  end

  def swap(diagram, swaplist) do
    swaplist
    |> Enum.reduce(diagram, fn {from, to}, diagram ->
      trans = Map.get(diagram, from)
      Map.put(diagram, from, Map.get(diagram, to))
      |> Map.put(to, trans)
    end)
  end

  def wire_name(a, i) do
    ii =
      Integer.to_string(i)
      |> String.pad_leading(2, "0")
    "#{a}#{ii}"
  end

  def word_width(diagram) do
    nx = count(diagram, &x_wire?/1)
    ny = count(diagram, &y_wire?/1)
    if nx != ny do
      raise "mismatch nx=#{nx} <> ny=#{ny}"
    end
    Logger.debug("word_width: x=#{nx} y=#{ny} z=#{nx + 1}")
    nx
  end

  defp count(diagram, f) do
    Map.keys(diagram)
    |> Enum.count(f)
  end

  def x_wire?(wire), do: wire_in_range?(wire, "x00", "x99")
  def y_wire?(wire), do: wire_in_range?(wire, "y00", "y99")
  def z_wire?(wire), do: wire_in_range?(wire, "z00", "z99")
  def xyz_wire?(wire), do: wire_in_range?(wire, "x00", "z99")
  defp wire_in_range?(w, a, b) when w >= a and w <= b, do: true
  defp wire_in_range?(_w, _a, _b), do: false

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
    if opts[:verbose], do: dumps(input_path)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_path) do
    parse_input_file(input_path)
    |> Wire.eval()
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_path) do
    parse_input_file(input_path)
    |> Wire.swapped_wires()
    |> Enum.join(",")
    |> IO.inspect(label: "Part 2 answer is")
  end

  @doc """
  Dump puzzle input adder and generated adder.
  """
  def dumps(input_path) do
    parse_input_file(input_path)
    |> Dumper.dump_adders()
  end
end
