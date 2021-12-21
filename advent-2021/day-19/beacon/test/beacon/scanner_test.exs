defmodule Beacon.ScannerTest do
  use ExUnit.Case
  doctest Beacon.Scanner

  alias Beacon.Correlator, as: Correlator
  alias Beacon.Scanner, as: Scanner

  # NB any variable with "beacon" in name is assumed **absolute**
  #    anything relative will have "rel_" in the name

  describe "puzzle example" do
    setup do
      [
        rel_beacon_sets: %{
          0 => [
            {404, -588, -901},
            {528, -643, 409},
            {-838, 591, 734},
            {390, -675, -793},
            {-537, -823, -458},
            {-485, -357, 347},
            {-345, -311, 381},
            {-661, -816, -575},
            {-876, 649, 763},
            {-618, -824, -621},
            {553, 345, -567},
            {474, 580, 667},
            {-447, -329, 318},
            {-584, 868, -557},
            {544, -627, -890},
            {564, 392, -477},
            {455, 729, 728},
            {-892, 524, 684},
            {-689, 845, -530},
            {423, -701, 434},
            {7, -33, -71},
            {630, 319, -379},
            {443, 580, 662},
            {-789, 900, -551},
            {459, -707, 401},
          ],
          1 => [
            {686, 422, 578},
            {605, 423, 415},
            {515, 917, -361},
            {-336, 658, 858},
            {95, 138, 22},
            {-476, 619, 847},
            {-340, -569, -846},
            {567, -361, 727},
            {-460, 603, -452},
            {669, -402, 600},
            {729, 430, 532},
            {-500, -761, 534},
            {-322, 571, 750},
            {-466, -666, -811},
            {-429, -592, 574},
            {-355, 545, -477},
            {703, -491, -529},
            {-328, -685, 520},
            {413, 935, -424},
            {-391, 539, -444},
            {586, -435, 557},
            {-364, -763, -893},
            {807, -499, -711},
            {755, -354, -619},
            {553, 889, -390},
          ],
          2 => [
            {649, 640, 665},
            {682, -795, 504},
            {-784, 533, -524},
            {-644, 584, -595},
            {-588, -843, 648},
            {-30, 6, 44},
            {-674, 560, 763},
            {500, 723, -460},
            {609, 671, -379},
            {-555, -800, 653},
            {-675, -892, -343},
            {697, -426, -610},
            {578, 704, 681},
            {493, 664, -388},
            {-671, -858, 530},
            {-667, 343, 800},
            {571, -461, -707},
            {-138, -166, 112},
            {-889, 563, -600},
            {646, -828, 498},
            {640, 759, 510},
            {-630, 509, 768},
            {-681, -892, -333},
            {673, -379, -804},
            {-742, -814, -386},
            {577, -820, 562},
          ],
          3 => [
            {-589, 542, 597},
            {605, -692, 669},
            {-500, 565, -823},
            {-660, 373, 557},
            {-458, -679, -417},
            {-488, 449, 543},
            {-626, 468, -788},
            {338, -750, -386},
            {528, -832, -391},
            {562, -778, 733},
            {-938, -730, 414},
            {543, 643, -506},
            {-524, 371, -870},
            {407, 773, 750},
            {-104, 29, 83},
            {378, -903, -323},
            {-778, -728, 485},
            {426, 699, 580},
            {-438, -605, -362},
            {-469, -447, -387},
            {509, 732, 623},
            {647, 635, -688},
            {-868, -804, 481},
            {614, -800, 639},
            {595, 780, -596},
          ],
          4 => [
            {727, 592, 562},
            {-293, -554, 779},
            {441, 611, -461},
            {-714, 465, -776},
            {-743, 427, -804},
            {-660, -479, -426},
            {832, -632, 460},
            {927, -485, -438},
            {408, 393, -506},
            {466, 436, -512},
            {110, 16, 151},
            {-258, -428, 682},
            {-393, 719, 612},
            {-211, -452, 876},
            {808, -476, -593},
            {-575, 615, 604},
            {-485, 667, 467},
            {-680, 325, -822},
            {-627, -443, -432},
            {872, -547, -609},
            {833, 512, 582},
            {807, 604, 487},
            {839, -516, 451},
            {891, -625, 532},
            {-652, -548, -490},
            {30, -46, -14},
          ],
        },
        origin_0: {0, 0, 0},
        t_1: 9,
        exp_origin_1: {68, -1246, -43},
        exp_beacons_1: [
          {-618, -824, -621},
          {-537, -823, -458},
          {-447, -329, 318},
          {404, -588, -901},
          {544, -627, -890},
          {528, -643, 409},
          {-661, -816, -575},
          {390, -675, -793},
          {423, -701, 434},
          {-345, -311, 381},
          {459, -707, 401},
          {-485, -357, 347},
        ],
        t_4: 24,
        exp_origin_4: {-20, -1133, 1061},
        exp_beacons_4: [
          {459, -707, 401},
          {-739, -1745, 668},
          {-485, -357, 347},
          {432, -2009, 850},
          {528, -643, 409},
          {423, -701, 434},
          {-345, -311, 381},
          {408, -1815, 803},
          {534, -1912, 768},
          {-687, -1600, 576},
          {-447, -329, 318},
          {-635, -1737, 486},
        ],
        exp_max_manhattan: 3621,
      ]
    end

    test "constructor produces expected scanner (scanner 0)", fixture do
      act_scanner_0 =
        Scanner.new(fixture.rel_beacon_sets[0], {0, 0, 0}, 1, {0, 0, 0})
      assert Scanner.origin(act_scanner_0) == {0, 0, 0}
      assert Scanner.beacons(act_scanner_0) == fixture.rel_beacon_sets[0]
    end

    test "constructor produces expected scanner (scanner 1)", fixture do
      act_scanner_1 = Scanner.new(fixture.rel_beacon_sets[1],
        fixture.origin_0, fixture.t_1, fixture.exp_origin_1)
      assert Scanner.origin(act_scanner_1) == fixture.exp_origin_1
      act_beacons_1 = Scanner.beacons(act_scanner_1)
      fixture.exp_beacons_1
      |> Enum.each(fn exp_beacon ->
        assert Enum.find(act_beacons_1, &(&1 == exp_beacon)) != nil
      end)
    end

    test "constructor produces expected scanner (scanner 4)", fixture do
      act_scanner_4 = Scanner.new(fixture.rel_beacon_sets[4],
        fixture.origin_0, fixture.t_4, fixture.exp_origin_4)
      assert Scanner.origin(act_scanner_4) == fixture.exp_origin_4
      act_beacons_4 = Scanner.beacons(act_scanner_4)
      fixture.exp_beacons_4
      |> Enum.each(fn exp_beacon ->
        assert Enum.find(act_beacons_4, &(&1 == exp_beacon)) != nil
      end)
    end

    test "computation of max Manhattan distance", fixture do
      # FIXME can use Beacon.build_cloud() here
      scanner_0 = Scanner.new(fixture.rel_beacon_sets[0], {0, 0, 0}, 1, {0, 0, 0})
      scanners =
        [1, 4, 2, 3]
        |> Enum.reduce({scanner_0, [scanner_0]}, fn (n, {cloud, scanners}) ->
          {t, offset, count} = Correlator.correlate(
            Scanner.beacons(cloud), fixture.rel_beacon_sets[n]
          )
          assert count >= 12
          scanner_n = Scanner.new(
            fixture.rel_beacon_sets[n], fixture.origin_0, t, offset
          )
          {Scanner.merge_beacons(cloud, scanner_n), [scanner_n | scanners]}
        end)
        |> elem(1)
      assert Scanner.max_manhattan(scanners) == fixture.exp_max_manhattan
    end
  end
end
