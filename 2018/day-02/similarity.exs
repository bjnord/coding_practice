# Day 2: Inventory Management System
#
# Part 2: Find two box IDs that differ in only one letter (same position)
#         What letters are common between the two correct box IDs?
#
# Correct answer: _

# NOTE my solution assumes all box IDs will be the same length

###
# functions needed for main stream
###

# return index of the only pair in list with different values
# (return nil if more or less than one differing pair exists)
pair_comparator = fn (pairs) ->
                    diff = Enum.map(pairs, fn ({a, b}) -> if a == b, do: 0, else: 1 end)
                           |> Enum.sum
                    if diff == 1 do
                      Enum.find_index(pairs, fn ({a, b}) -> a != b end)
                    else
                      nil
                    end
                  end

# return position where strings differ, if they differ in exactly one position
# (return nil if they differ in more or less than one position)
str_comparator = fn (a, b) -> pair_comparator.(Enum.zip(String.graphemes(a), String.graphemes(b))) end

IO.inspect(str_comparator.("abcde", "abxdy"))
IO.inspect(str_comparator.("abcde", "abxde"))
IO.inspect(str_comparator.("abcde", "abcde"))
