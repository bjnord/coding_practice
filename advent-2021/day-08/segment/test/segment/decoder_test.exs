defmodule Segment.DecoderTest do
  use ExUnit.Case
  doctest Segment.Decoder

  alias Segment.Decoder
  alias Segment.Parser

  describe "puzzle example" do
    setup do
      [
        note_lines: """
        be cfbegad cbdgef fgaecd cgeb fdcge agebfd fecdb fabcd edb | fdgacbe cefdb cefbgd gcbe
        edbfga begcd cbg gc gcadebf fbgde acbgfd abcde gfcbed gfec | fcgedb cgb dgebacf gc
        fgaebd cg bdaec gdafb agbcfd gdcbef bgcad gfac gcb cdgabef | cg cg fdcagb cbg
        fbegcd cbd adcefb dageb afcb bc aefdc ecdab fgdeca fcdbega | efabcd cedba gadfec cb
        aecbfdg fbg gf bafeg dbefa fcge gcbea fcaegb dgceab fcbdga | gecf egdcabf bgf bfgea
        fgeab ca afcebg bdacfeg cfaedg gcfdb baec bfadeg bafgc acf | gebdcfa ecba ca fadegcb
        dbcfg fgd bdegcaf fgec aegbdf ecdfab fbedc dacgb gdcebf gf | cefg dcbef fcge gbcadfe
        bdfegc cbegaf gecbf dfcage bdacg ed bedf ced adcbefg gebcd | ed bcgafe cdgba cbgef
        egadfb cdbfeg cegd fecab cgb gbdefca cg fgcdab egfdb bfceg | gbdfcae bgc cg cgb
        gcafb gcf dcaebfg ecagb gf abcdeg gaef cafbge fdbac fegbdc | fgae cfgab fg bagce
        """,
        exp_digits: "8394 9781 1197 9361 4873 8418 4548 1625 8717 4315",
        exp_part2: 61229,
      ]
    end

    test "get correct digits from output values", fixture do
      act_digits =
        fixture.note_lines
        |> Parser.parse()
        |> Enum.map(&Decoder.digits_of_note/1)
        |> Enum.join(" ")
      assert act_digits == fixture.exp_digits
    end

    test "get correct part 2 answer", fixture do
      act_part2 =
        fixture.note_lines
        |> Parser.parse()
        |> Enum.map(&Decoder.digits_of_note/1)
        |> Enum.map(&String.to_integer/1)
        |> Enum.sum()
      assert act_part2 == fixture.exp_part2
    end
  end
end
