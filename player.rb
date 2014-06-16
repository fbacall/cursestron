class Player
  attr_accessor :position
  attr_accessor :direction
  attr_reader :number
  attr_reader :colour
  attr_reader :controls
  attr_accessor :score
  attr_accessor :dead

  def initialize(controls, x, y, dirx, diry, number, colour)
    @start_position = [x,y]
    @start_direction = [dirx, diry]
    @position = []
    @direction = []

    @number = number
    @colour = colour
    @controls = { :up => controls[0],
                  :down => controls[1],
                  :left => controls[2],
                  :right => controls[3]}
    reset
    @score = 0
  end

  def reset
    @position[0] = @start_position[0]
    @position[1] = @start_position[1]
    @direction[0] = @start_direction[0]
    @direction[1] = @start_direction[1]
    @dead = false
  end

  def move
    @position[0] += @direction[0]
    @position[1] += @direction[1]
  end
end
