defmodule SegmentPWeb.PartsController do
  use SegmentPWeb, :controller

  def index(conn, _params) do
    input =
      File.read!("../segment/input/input.txt")
      |> Segment.Parser.parse()
    part1 =
      input
      |> Enum.map(&Segment.count_unique/1)
      |> Enum.sum()
    part2 =
      input
      |> Enum.map(&Segment.Decoder.digits_of_note/1)
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    render(conn, "index.html", part1: part1, part2: part2)
  end
end
