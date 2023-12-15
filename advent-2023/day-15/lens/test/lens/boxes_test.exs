defmodule Lens.BoxesTest do
  use ExUnit.Case
  doctest Lens.Boxes, import: true

  alias Lens.Boxes

  describe "puzzle example" do
    setup do
      [
        iv: [
          {0, :install, "rn", 1},
          {0, :remove,  "cm"},
          {1, :install, "qp", 3},
          {0, :install, "cm", 2},
          {1, :remove,  "qp"},
          {3, :install, "pc", 4},
          {3, :install, "ot", 9},
          {3, :install, "ab", 5},
          {3, :remove,  "pc"},
          {3, :install, "pc", 6},
          {3, :install, "ot", 7},
        ],
        exp_boxes: %{
          0 => [
            {"rn", 1},
            {"cm", 2},
          ],
          1 => [
          ],
          3 => [
            {"ot", 7},
            {"ab", 5},
            {"pc", 6},
          ],
        },
      ]
    end

    test "install lenses in boxes", fixture do
      act_boxes = fixture.iv
                  |> Boxes.install()
      assert act_boxes == fixture.exp_boxes
    end
  end
end
