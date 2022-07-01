# frozen_string_literal: true

# __Further Exploration__
#
# The Number Guesser game is mostly self-contained, and I think it should stay
# that way. I couldn't think of anything player-specific to extract.
#
# A `Player` class would have player-specific state and behaviors, like language,
# stats, a list of games they own or to which they subscribe, etc. Here's how I
# would use a `Player` class with other game-related classes to enable
# polymorphically selecting and playing one of any number of available games:
#
# 1. A generalized `Player` class from Tic Tac Toe, Twenty One or any other game.
#    Determine what's player-specific--nothing that applies to specific games.
#    It would also include a list of games associated with the player (their
#    "game library").
# 2. A `Game` class that all core game classes can inherit for common game state
#    and behaviors. Initialize it with a `Player` instance with which `Game`
#    objects will collaborate.
# 3. A `GameLauncher` class that lists the player's available games and
#    coordinates game selection and instantiation.

module Common
  def self.clear_console
    system('clear')
  end

  def self.display_empty_line
    puts
  end
end

# The core game class within a game module inherits this class.
# Subclass requirements to enable polymorphic game selection and instantiation:
# - Subclass name: GameCore
# - Required methods:
#   - `self.name`: return the user-visible game name.
#   - `initialize(player)`
# - Typically overridden methods:
#   - `play`: start the game.
class Game
  def initialize(player)
    @player = player
  end

  # `GameCore` subclass must override this `play` method to enable the
  # `GameLauncher` module to polymorphically start it.
  def play
    Common.clear_console
    puts "Hey, #{player.name}, welcome to -Demo- #{self.class.name}!"
    puts "\n**This `#{__method__}` method is defined in the `#{self.class.superclass}` superclass.**" \
         "\nOverride `#{__method__}` in `#{self.class}` so this invocation launches " \
         "the game--don't call `super` in the overriding method." \
         "\n\nPress enter to continue..."
    gets
  end

  private

  attr_reader :player
end

# All game modules `extend` this module to enable polymorphic game selection
# and instantiation.
module GameModule
  # Override this method in the including module has a different `Game` subclass
  # of a different name that can't be changed for some reason.
  def game_core_symbol
    :GameCore
  end

  def game_core_class
    const_get(game_core_symbol)
  end

  def game_name
    game_core_class.name
  end

  def create_game_core(player)
    game_core_class.new(player)
  end
end

# This module would contain all Tic Tac Toe game classes (probably split across
# separate files, but we haven't learned that yet).
module TicTacToe
  extend GameModule
  # Launch School hasn't taught us about `extend` yet. Basically, it's similar to
  # `include`ing a module in a class, but here, `extend` "adds" the GameModule
  # methods to this module's `self` context, i.e., `GameModule#game_core_class`
  # is defined like this: `def self.game_core_class...`
  # ***
  # That allows invoking methods like this:
  # TicTacToe.game_core_class, TwentyOne.game_core_class, etc.

  # This class would contain the core/top-level Tic Tac Toe game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.

    def self.name
      'Tic Tac Toe'
    end
  end
end

# Another game module.
module TwentyOne
  extend GameModule

  # This class would contain the core Twenty One game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.

    def self.name
      'Twenty One'
    end
  end
end

# Another game module.
module NumberGuesser
  extend GameModule

  # This class would contain the core Number Guesser game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.

    def self.name
      'Number Guesser'
    end
  end
end

# Game selection and instantiation.
class GameLauncher
  attr_reader :player

  def initialize(player)
    @player = player
    @game_core = nil
  end

  def play
    loop do
      select_game
      game_core.play

      print 'Would you like to play another game? (Y/N)'
      play_again = gets.chomp
      break unless play_again.downcase == 'y'
    end

    # What else might we want to do when a player is done for now?
  end

  private

  attr_accessor :game_core

  def select_game
    selected_title = prompt_game_title
    game_index = game_names.map(&:downcase).index(selected_title.downcase)
    self.game_core = available_games[game_index].create_game_core(player)
  end

  def prompt_game_title
    Common.clear_console
    puts "What game would you like to play, #{player.name}?"
    puts game_names
    Common.display_empty_line
    print '> '
    gets.chomp
  end

  def game_names
    available_games.map(&:game_name)
  end

  def available_games
    player.available_games
  end
end

class Player
  attr_reader :name, :available_games

  # The program would want additional user details, including a unique ID,
  # that any game would use, but we'll keep it simple for demo purposes:
  def initialize(name)
    @name = name
    # A program like this would probably load games based on player preferences;
    # for now, we'll pass a static array of all game modules:
    @available_games = [TicTacToe, TwentyOne, NumberGuesser]

    # ...initialize other player-specific state, such as display name, ID, etc....
  end

  def self.identify
    Common.clear_console
    puts "Hi, what's your name?"
    gets.strip
  end
end

player_one = Player.new(Player.identify)
# `player_one` is logged in and ready to start at this point!
# Pass that object to a new `GameLauncher` instance, which provides
# the game launch interface:
game_launcher = GameLauncher.new(player_one)
game_launcher.play
