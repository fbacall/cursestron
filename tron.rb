require 'curses'

require_relative('player.rb')
require_relative('game.rb')

Curses.noecho
Curses.init_screen
Curses.start_color

Curses.init_pair(Curses::COLOR_BLUE,Curses::COLOR_WHITE,Curses::COLOR_BLUE)
Curses.init_pair(Curses::COLOR_RED,Curses::COLOR_WHITE,Curses::COLOR_RED)
Curses.init_pair(Curses::COLOR_YELLOW,Curses::COLOR_WHITE,Curses::COLOR_YELLOW)
Curses.init_pair(Curses::COLOR_GREEN,Curses::COLOR_WHITE,Curses::COLOR_GREEN)

stop = false

width = Curses.cols
height = Curses.lines

players = [Player.new('wsad', 10, 10, 0, 1, 1, Curses::COLOR_BLUE),
           Player.new('ikjl', (width - 10), (height - 10), 0, -1, 2, Curses::COLOR_RED),
           Player.new('tgfh', (width - 10), 10, -1, 0, 3, Curses::COLOR_YELLOW),
           Player.new("[';#", 10, (height - 10), 1, 0, 4, Curses::COLOR_GREEN)]

player_count = ARGV[0].to_i || 2
player_count = 4 if player_count > 4
player_count = 2 if player_count < 2

until stop do
  # Start game
  game = Game.new(width, height, players[0...player_count])

  # Display controls for each player
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

  # Display game instructions
  instructions_str = "Press any key to start!"
  instructions = game.window.subwin(7, instructions_str.length + 4, (height / 2) - 4, (width - instructions_str.length + 4) / 2)
  instructions.box('|', '-')
  instructions.setpos(2, 2)
  instructions.addstr(instructions_str)
  instructions.setpos(4, 6)
  instructions.addstr("Press Q to quit")
  instructions.refresh

  start_windows << instructions

  game.window.getch
  start_windows.each {|w| w.clear; w.close}

  # Draw scores
  x_pos = 3
  game.players.each do |player|
    str = "(Player #{player.number}): #{player.score}"
    game.window.setpos(height - 1, x_pos)
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
              player.direction = [0, -1] unless player.direction[1] == 1
            when player.controls[:down]
              player.direction = [0, 1] unless player.direction[1] == -1
            when player.controls[:left]
              player.direction = [-1, 0] unless player.direction[0] == 1
            when player.controls[:right]
              player.direction = [1, 0] unless player.direction[0] == -1
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
  if game.window.getch == 'n'
    stop = true
  end
end
