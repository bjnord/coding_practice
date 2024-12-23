defmodule Network do
  @moduledoc """
  Documentation for `Network`.
  """

  import Network.Parser
  import History.CLI

  def t_triads(connections) do
    connections
    |> form_network()
    |> triads()
  end

  def form_network(connections) do
    connections
    |> Enum.reduce(%{}, fn {a, b}, acc ->
      acc
      |> connect(a, b)
      |> connect(b, a)
    end)
  end

  def connect(network, a, b) do
    Map.update(network, a, MapSet.new([b]), fn nodes ->
      MapSet.put(nodes, b)
    end)
  end

  def triads(network) do
    Map.keys(network)
    |> Enum.filter(&starts_t?/1)
    |> Enum.sort()
    |> Enum.flat_map(fn node ->
      peers = Map.get(network, node)
      MapSet.to_list(peers)
      |> Enum.reduce({peers, []}, fn a, {rem_peers, acc} ->
        rem_peers =
          MapSet.delete(rem_peers, a)
        acc =
          MapSet.to_list(rem_peers)
          |> Enum.reduce(acc, fn b, acc ->
            if connects_to?(network, a, b) do
              [Enum.sort([node, a, b]) | acc]
            else
              acc
            end
          end)
        {rem_peers, acc}
      end)
      |> elem(1)
      |> Enum.reverse()
    end)
    |> Enum.sort()
    |> Enum.uniq()
  end

  defp starts_t?(node) do
    String.starts_with?(node, "t")
  end

  def connects_to?(network, a, b) do
    Map.get(network, a)
    |> MapSet.member?(b)
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
    |> Network.t_triads()
    |> Enum.count()
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