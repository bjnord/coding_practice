defmodule Runes.ParserTest do
  use ExUnit.Case
  doctest Runes.Parser, import: true

  alias Runes.Artifact
  import Runes.Parser

  describe "input parser" do
    setup do
      [
        inputs: [
          # Part I
          """
          WORDS:THE,OWE,MES,ROD,HER

          AWAKEN THE POWER ADORNED WITH THE FLAMES BRIGHT IRE
          """,
          # Part II
          """
          WORDS:THE,OWE,MES,ROD,HER,QAQ

          AWAKEN THE POWE ADORNED WITH THE FLAMES BRIGHT IRE
          THE FLAME SHIELDED THE HEART OF THE KINGS
          POWE PO WER P OWE R
          THERE IS THE END
          QAQAQ
          """,
          # Part III
          """
          WORDS:THE,OWE,MES,ROD,RODEO

          HELWORLT
          ENIGWDXL
          TRODEOAL
          """,
        ],
        exp_artifacts: [
          %Artifact{
            words: [~c"THE", ~c"OWE", ~c"MES", ~c"ROD", ~c"HER"],
            height: 1,
            widths: [51],
            grid: %{
              {0,  0} => ?A, {0,  1} => ?W, {0,  2} => ?A, {0,  3} => ?K,
              {0,  4} => ?E, {0,  5} => ?N, {0,  6} => 32, {0,  7} => ?T,
              {0,  8} => ?H, {0,  9} => ?E, {0, 10} => 32, {0, 11} => ?P,
              {0, 12} => ?O, {0, 13} => ?W, {0, 14} => ?E, {0, 15} => ?R,
              {0, 16} => 32, {0, 17} => ?A, {0, 18} => ?D, {0, 19} => ?O,
              {0, 20} => ?R, {0, 21} => ?N, {0, 22} => ?E, {0, 23} => ?D,
              {0, 24} => 32, {0, 25} => ?W, {0, 26} => ?I, {0, 27} => ?T,
              {0, 28} => ?H, {0, 29} => 32, {0, 30} => ?T, {0, 31} => ?H,
              {0, 32} => ?E, {0, 33} => 32, {0, 34} => ?F, {0, 35} => ?L,
              {0, 36} => ?A, {0, 37} => ?M, {0, 38} => ?E, {0, 39} => ?S,
              {0, 40} => 32, {0, 41} => ?B, {0, 42} => ?R, {0, 43} => ?I,
              {0, 44} => ?G, {0, 45} => ?H, {0, 46} => ?T, {0, 47} => 32,
              {0, 48} => ?I, {0, 49} => ?R, {0, 50} => ?E,
            },
          },
          %Artifact{
            words: [~c"THE", ~c"OWE", ~c"MES", ~c"ROD", ~c"HER", ~c"QAQ"],
            height: 5,
            widths: [50, 41, 19, 16, 5],
            grid: %{
              {0,  0} => ?A, {0,  1} => ?W, {0,  2} => ?A, {0,  3} => ?K,
              {0,  4} => ?E, {0,  5} => ?N, {0,  6} => 32, {0,  7} => ?T,
              {0,  8} => ?H, {0,  9} => ?E, {0, 10} => 32, {0, 11} => ?P,
              {0, 12} => ?O, {0, 13} => ?W, {0, 14} => ?E, {0, 15} => 32,
              {0, 16} => ?A, {0, 17} => ?D, {0, 18} => ?O, {0, 19} => ?R,
              {0, 20} => ?N, {0, 21} => ?E, {0, 22} => ?D, {0, 23} => 32,
              {0, 24} => ?W, {0, 25} => ?I, {0, 26} => ?T, {0, 27} => ?H,
              {0, 28} => 32, {0, 29} => ?T, {0, 30} => ?H, {0, 31} => ?E,
              {0, 32} => 32, {0, 33} => ?F, {0, 34} => ?L, {0, 35} => ?A,
              {0, 36} => ?M, {0, 37} => ?E, {0, 38} => ?S, {0, 39} => 32,
              {0, 40} => ?B, {0, 41} => ?R, {0, 42} => ?I, {0, 43} => ?G,
              {0, 44} => ?H, {0, 45} => ?T, {0, 46} => 32, {0, 47} => ?I,
              {0, 48} => ?R, {0, 49} => ?E,
              {1,  0} => ?T, {1,  1} => ?H, {1,  2} => ?E, {1,  3} => 32,
              {1,  4} => ?F, {1,  5} => ?L, {1,  6} => ?A, {1,  7} => ?M,
              {1,  8} => ?E, {1,  9} => 32, {1, 10} => ?S, {1, 11} => ?H,
              {1, 12} => ?I, {1, 13} => ?E, {1, 14} => ?L, {1, 15} => ?D,
              {1, 16} => ?E, {1, 17} => ?D, {1, 18} => 32, {1, 19} => ?T,
              {1, 20} => ?H, {1, 21} => ?E, {1, 22} => 32, {1, 23} => ?H,
              {1, 24} => ?E, {1, 25} => ?A, {1, 26} => ?R, {1, 27} => ?T,
              {1, 28} => 32, {1, 29} => ?O, {1, 30} => ?F, {1, 31} => 32,
              {1, 32} => ?T, {1, 33} => ?H, {1, 34} => ?E, {1, 35} => 32,
              {1, 36} => ?K, {1, 37} => ?I, {1, 38} => ?N, {1, 39} => ?G,
              {1, 40} => ?S,
              {2,  0} => ?P, {2,  1} => ?O, {2,  2} => ?W, {2,  3} => ?E,
              {2,  4} => 32, {2,  5} => ?P, {2,  6} => ?O, {2,  7} => 32,
              {2,  8} => ?W, {2,  9} => ?E, {2, 10} => ?R, {2, 11} => 32,
              {2, 12} => ?P, {2, 13} => 32, {2, 14} => ?O, {2, 15} => ?W,
              {2, 16} => ?E, {2, 17} => 32, {2, 18} => ?R,
              {3,  0} => ?T, {3,  1} => ?H, {3,  2} => ?E, {3,  3} => ?R,
              {3,  4} => ?E, {3,  5} => 32, {3,  6} => ?I, {3,  7} => ?S,
              {3,  8} => 32, {3,  9} => ?T, {3, 10} => ?H, {3, 11} => ?E,
              {3, 12} => 32, {3, 13} => ?E, {3, 14} => ?N, {3, 15} => ?D,
              {4,  0} => ?Q, {4,  1} => ?A, {4,  2} => ?Q, {4,  3} => ?A,
              {4,  4} => ?Q,
            },
          },
          %Artifact{
            words: [~c"THE", ~c"OWE", ~c"MES", ~c"ROD", ~c"RODEO"],
            height: 3,
            widths: [8, 8, 8],
            grid: %{
              {0, 0} => ?H, {0, 1} => ?E, {0, 2} => ?L, {0, 3} => ?W,
              {0, 4} => ?O, {0, 5} => ?R, {0, 6} => ?L, {0, 7} => ?T,
              {1, 0} => ?E, {1, 1} => ?N, {1, 2} => ?I, {1, 3} => ?G,
              {1, 4} => ?W, {1, 5} => ?D, {1, 6} => ?X, {1, 7} => ?L,
              {2, 0} => ?T, {2, 1} => ?R, {2, 2} => ?O, {2, 3} => ?D,
              {2, 4} => ?E, {2, 5} => ?O, {2, 6} => ?A, {2, 7} => ?L,
            },
          },
        ],
      ]
    end

    test "produces expected artifacts", fixture do
      act_artifacts =
        fixture.inputs
        |> Enum.map(&parse_input_string/1)
      assert act_artifacts == fixture.exp_artifacts
    end
  end
end