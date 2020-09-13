class Walker
  START_SUM = 22
  VAULT_SUM = 30
  MAX_MOVES = 12
  DIR = {
    north: [1, 0],
    south: [-1, 0],
    east: [0, 1],
    west: [0, -1],
  }
  MAZE = {
     0 => nil,
     1 => '-',
     2 => 9,
     3 => '*',
     4 => '+',
     5 => 4,
     6 => '-',
     7 => 18,
     8 => 4,
     9 => '*',
    10 => 11,
    11 => '*',
    12 => '*',
    13 => 8,
    14 => '-',
    15 => 1,
  }

  def initialize
    @posy = 0
    @posx = 0
    @path = []
    @sum = START_SUM
    @op = nil
  end

  def walk
    [:north, :east].each do |dir|
      move(dir)
    end
  end

  def manhattan(y, x)
    (3 - y) + (3 - x)
  end

  def move(dir)
    newy = @posy + DIR[dir][0]
    return unless newy.between?(0, 3)
    newx = @posx + DIR[dir][1]
    return unless newx.between?(0, 3)
    return unless floor = MAZE[newy * 4 + newx]
    return unless manhattan(newy, newx) + @path.size + 1 <= MAX_MOVES
    oldy = @posy
    oldx = @posx
    oldop = @op
    oldsum = @sum
    case floor.class.name
    when 'Integer'
      raise "#{[@posy, @posx]} #{dir} #{[newy, newx]} #{floor} op=#{@op} saw Integer" if !@op
      case @op
      when '+'
        @sum += floor
      when '-'
        @sum -= floor
      when '*'
        @sum *= floor
      else
        raise "#{[@posy, @posx]} #{dir} #{[newy, newx]} #{floor} op=#{@op} invalid"
      end
      @op = nil
    when 'String'
      raise "#{[@posy, @posx]} #{dir} #{[newy, newx]} #{floor} op=#{@op} saw String" if @op
      @op = floor
    else
      raise "#{[@posy, @posx]} #{dir} #{[newy, newx]} #{floor} op=#{@op} saw #{floor.class.name}"
    end
    @posy = newy
    @posx = newx
    @path.push(dir)
    if (@posy == 3) && (@posx == 3)
      puts "solution in #{@path.size} moves! #{@path}" if @sum == VAULT_SUM
      # once we arrive at the vault, we can't continue past it;
      # orb vanishes if we don't have the right weight
    else
      [:north, :south, :east, :west].each do |dir|
        move(dir)
      end
    end
    @path.pop
    @posx = oldx
    @posy = oldy
    @sum = oldsum
    @op = oldop
  end
end
