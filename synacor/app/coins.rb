class Coins
  # _ + _ * _^2 + _^3 - _ = 399
  ANSWER = 399
  COINS = {
    :red => 2,
    :blue => 9,
    :shiny => 5,
    :concave => 7,
    :corroded => 3,
  }

  def self.solutions
    COINS.keys.permutation.collect do |perm|
      values = perm.map{|coin| COINS[coin] }
      answer = values[0] + values[1] * values[2].pow(2) + values[3].pow(3) - values[4]
      (answer == ANSWER) ? values.map{|value| COINS.key(value) } : nil
    end.reject{|perm| perm.nil? }
  end
end
