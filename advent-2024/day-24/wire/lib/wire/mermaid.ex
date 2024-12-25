defmodule Wire.Mermaid do
  @moduledoc """
  Documentation for `Wire.Mermaid`.
  """

  def write_diagram(diagram, path) do
    {:ok, f} = File.open(path, [:write])
    IO.binwrite(f, "graph TD\n")
    Map.keys(diagram)
    |> Enum.each(fn wire ->
      mermaid_node(f, wire, Map.get(diagram, wire))
    end)
    File.close(f)
  end

  defp mermaid_node(f, wire, {wire1, gate, wire2}) do
    IO.binwrite(f, "#{wire}-->#{wire}#{gate}\n")
    IO.binwrite(f, "#{wire}#{gate}-->#{wire1}\n")
    IO.binwrite(f, "#{wire}#{gate}-->#{wire2}\n")
  end
  defp mermaid_node(_f, _wire, _value), do: :ok
end
