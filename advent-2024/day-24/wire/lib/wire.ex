defmodule Wire do
  @moduledoc """
  Documentation for `Wire`.
  """

  import Bitwise
  import History.CLI
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

  defp z_wire?(wire) do
    Atom.to_string(wire)
    |> String.first()
    |> then(fn gr -> gr == "z" end)
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

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_path, opts} = parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_path)
    if Enum.member?(opts[:parts], 2), do: part2(input_path)
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
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
