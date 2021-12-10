defmodule SyntaxTest do
  use ExUnit.Case
  doctest Syntax

  describe "puzzle example" do
    setup do
      [
        entries: [
          '[({(<(())[]>[[{[]{<()<>>',
          '[(()[<>])]({[<{<<[]>>(',
          '{([(<{}[<>[]}>{[]{[(<()>',
          '(((({<>}<{<{<>}{[]{[]{}',
          '[[<[([]))<([[{}[[()]]]',
          '[{[{({}]{}}([{[{{{}}([]',
          '{<[[]]>}<{[{[{[]{()[[[]',
          '[<(<(<(<{}))><([]([]()',
          '<{([([[(<>()){}]>(<<{{',
          '<{([{{}}[<[[[<>{}]]]>[]]',
        ],
        exp_corrupted_entries: [
          {:corrupted, '}>{[]{[(<()>'},
          {:corrupted, ')<([[{}[[()]]]'},
          {:corrupted, ']{}}([{[{{{}}([]'},
          {:corrupted, '))><([]([]()'},
          {:corrupted, '>(<<{{'},
        ],
        exp_corrupted_entry_scores: [1197, 3, 57, 3, 25137]
      ]
    end

    test "status checker finds corrupted entries", fixture do
      act_corrupted = fixture.entries
                      |> Enum.map(&Syntax.entry_status/1)
                      |> Enum.filter(fn {status, _chars} -> status == :corrupted end)
      assert act_corrupted == fixture.exp_corrupted_entries
    end

    test "corrupted entry scorer finds correct scores", fixture do
      act_scores = fixture.entries
                   |> Enum.map(&Syntax.entry_status/1)
                   |> Enum.filter(fn {status, _chars} -> status == :corrupted end)
                   |> Enum.map(&Syntax.entry_score/1)
      assert act_scores == fixture.exp_corrupted_entry_scores
    end
  end
end
