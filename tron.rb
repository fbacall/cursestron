require 'curses'

Curses.noecho
Curses.init_screen
Curses.start_color

Curses.init_pair(Curses::COLOR_BLUE,Curses::COLOR_WHITE,Curses::COLOR_BLUE)
Curses.init_pair(Curses::COLOR_RED,Curses::COLOR_WHITE,Curses::COLOR_RED)

stop = false

class Game
  attr_accessor :grid
  attr_reader :window
  attr_reader :players
  attr_accessor :active

  def initialize(width, height, players)
    @width = width
    @height = height

    @grid = Array.new(width) { Array.new(height) }
    @players = players

    @window = Curses::Window.new(height, width, 0, 0)
    @window.box("|", "-")

    @active = true
  end

  def update
    players.each do |player|
      player.move

      if player.position[0] < 1 || player.position[0] > @width - 1 ||
          player.position[1] < 1 || player.position[1] > @height - 1 ||
          !@grid[player.position[0]][player.position[1]].nil?

        @active = false
        str = "Player #{player.number} died"
        @window.setpos(@height / 2, (@width - str.length) / 2)
        @window.attron(Curses.color_pair(player.colour)|Curses::A_NORMAL) do
          @window.addstr("Player #{player.number} died")
        end
        @window.refresh
      else
        @window.setpos(player.position[1], player.position[0])
        @window.attron(Curses.color_pair(player.colour)|Curses::A_NORMAL) do
          @window.addstr(' ')
        end
        @grid[player.position[0]][player.position[1]] = player.number
      end
    end

    @window.setpos(0,0)
    @window.refresh
  end

end

class Player
  attr_accessor :position
  attr_accessor :direction
  attr_reader :number
  attr_reader :colour
  attr_reader :controls
  attr_accessor :score

  def initialize(controls, x, y, dirx, diry, number, colour)
    @start_position = [x,y]
    @start_direction = [dirx, diry]
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
    @position = @start_position
    @direction = @start_direction
  end

  def move
    @position[0] += @direction[0]
    @position[1] += @direction[1]
  end
end

width = Curses.cols
height = Curses.lines

players = [Player.new('wsad', 10, 10, 0, 1, 1, Curses::COLOR_BLUE),
           Player.new('ikjl', (width - 10), (height - 10), 0, -1, 2, Curses::COLOR_RED)]

until stop do
  # Start game
  game = Game.new(width, height, players)

  start_windows = game.players.map do |player|
    win = game.window.subwin(10, 16, player.position[1] - 5, player.position[0] - 8)
    win.box("|", "-")
    win.setpos(0,4)
    win.attron(Curses.color_pair(player.colour)|Curses::A_NORMAL) do
      win.addstr("Player #{player.number}")
    end
    win.setpos(2,2)
    win.addstr("#{player.controls[:up]} - Up")
    win.setpos(4,2)
    win.addstr("#{player.controls[:down]} - Down")
    win.setpos(6,2)
    win.addstr("#{player.controls[:left]} - Left")
    win.setpos(8,2)
    win.addstr("#{player.controls[:right]} - Right")
    win.refresh
    win
  end

  instructions_str = "Press any key to start!"
  instructions = game.window.subwin(7, instructions_str.length + 4, (height / 2) - 4, (width - instructions_str.length + 4) / 2)
  instructions.setpos(4, 2)
  instructions.addstr("Press any key to start!")
  instructions.refresh

  start_windows << instructions

  game.window.getch
  start_windows.each {|w| w.clear; w.close}

  # Draw scores
  x_pos = 4
  game.players.each do |player|
    str = "(Player #{player.number}): #{player.score}"
    game.window.setpos(height, x_pos)
    game.window.attron(Curses.color_pair(player.colour)|Curses::A_NORMAL) do
      game.window.addstr(str)
    end
    x_pos += (str.length + 2)
  end

  game.window.refresh


  # Controls
  t = Thread.new do
    while game.active do
      input = game.window.getch

      if input == 'q'
        game.active = false
        stop = true
      else
        game.players.each do |player|
          case input
            when player.controls[:up]
              player.direction = [0, -1]
            when player.controls[:down]
              player.direction = [0, 1]
            when player.controls[:left]
              player.direction = [-1, 0]
            when player.controls[:right]
              player.direction = [1, 0]
          end
        end
      end
    end
  end

  # Main loop
  while game.active do
    sleep 0.1
    game.update
  end

  t.join

end

game.window.close
