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
