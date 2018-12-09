defmodule Day1 do
  def repeated_frequency(file_stream) do
    file_stream
    |> Stream.map(fn line ->
      {integer, _leftover} = Integer.parse(line)
      integer
    end)
    |> Stream.cycle()
    |> Enum.reduce_while({0, MapSet.new([0])}, fn x, {current_frequency, seen_frequencies} ->
      new_frequency = current_frequency + x

      if new_frequency in seen_frequencies do
        {:halt, new_frequency}
      else
        {:cont, {new_frequency, MapSet.put(seen_frequencies, new_frequency)}}
      end
    end)
  end
end

case System.argv() do
  ["--test"] ->
    ExUnit.start()

    defmodule Day1Test do
      use ExUnit.Case

      import Day1

      test "final_frequency" do
        assert repeated_frequency([
          "+1\n",
          "-2\n",
          "+3\n",
          "+1\n"
        ]) == 2
      end
    end

  [input_file] ->
    input_file
    |> File.stream!([], :line)
    |> Day1.repeated_frequency()
    |> IO.puts

  _ ->
    IO.puts :stderr, "we expected --test or an input file"
    System.halt(1)
end
