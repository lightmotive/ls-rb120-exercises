# frozen_string_literal: true

# __Further Exploration__
#
# The Number Guesser game is mostly self-contained, and I think it should stay
# that way. I couldn't think of anything to extract that is player-specific.
#
# A `Player` class would have player-specific state and behaviors, like language,
# stats, a list of games they own or to which they subscribe, etc. Here's how I
# would use a `Player` class and other game-related classes to enable
# polymorphically selecting and playing one of any number of available games,
# including an option to play another game when the last game ends:
#
# - Generalize a `Player` class from Tic Tac Toe, Twenty One or any other game.
#   Determine what's player-specific--nothing that applies to specific games.
# - Define a `Game` class that all core game classes can inherit for common game
#   state and behaviors.
# - Define a `GameLauncher` class that lists available games--`Game` subclasses--and
#   acts as a standard interface between `Player` and `Game`.
# - Implement the `GameLauncher` class as a collaborator in `Player` that enable
#   the player to select and play games with a single call to `play`.

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
# - Class name: GameCore
# - Required methods:
#   - `initialize(game_launcher)`
#     - Initialize with one argument: a `GameLauncher` class instance (object).
# - Typically overridden methods:
#   - `play`: start the game.
class Game
  def initialize(game_launcher)
    @game_launcher = game_launcher
  end

  # `GameCore` subclass must override this `play` method to enable the
  # `GameLauncher` module to polymorphically start it.
  def play
    Common.clear_console
    puts "Hey, #{game_launcher.player_name}, welcome to -Demo- #{self.class.name}!"
    puts "\n**This `#{__method__}` method is defined in the `#{self.class.superclass}` superclass.**" \
         "\nOverride this method in `#{self.class}` so this invocation launches " \
         "the game, instead--don't call `super` in the overriding method." \
         "\n\nPress enter to continue..."
    gets
  end

  private

  attr_reader :game_launcher
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
    name
  end

  def create_game_core(game_launcher)
    game_core_class.new(game_launcher)
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

  def self.name
    'Tic Tac Toe'
  end

  # This class would contain the core/top-level Tic Tac Toe game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.
  end
end

# Another game module.
module TwentyOne
  extend GameModule

  def self.name
    'Twenty One'
  end

  # This class would contain the core Twenty One game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.
  end
end

# Another game module.
module NumberGuesser
  extend GameModule

  def self.name
    'Number Guesser'
  end

  # This class would contain the core Number Guesser game logic...
  class GameCore < Game
    # `initialize` is optional here; implement `play` here to override superclass.
  end
end

# Use this as a collaborator object in a `Player` class.
class GameLauncher
  # The game launcher would want additional user details, including a
  # unique ID, to forward on to each game, but we'll keep it simple here for
  # demo purposes:
  attr_reader :player_name

  def initialize(available_games, player_name)
    @available_games = available_games
    @player_name = player_name
    @game_core = nil
  end

  def select_game
    selected_title = prompt_game_title
    game_index = game_names.map(&:downcase).index(selected_title.downcase)
    self.game_core = available_games[game_index].create_game_core(self)
  end

  def play
    game_core.play
  end

  def self.prompt_player_name
    Common.clear_console
    puts "Hi, welcome to Game Launcher! What's your name?"
    gets.strip
  end

  private

  attr_reader :available_games
  attr_accessor :game_core

  def prompt_game_title
    Common.clear_console
    puts "What game would you like to play, #{player_name}?"
    puts game_names
    Common.display_empty_line
    print '> '
    gets.chomp
  end

  def game_names
    available_games.map(&:game_name)
  end
end

class Player
  attr_reader :name

  def initialize
    @name = GameLauncher.prompt_player_name

    # ...initialize other player-specific state, such as display name, ID, etc....

    # A program like this would probably load games based on player preferences;
    # for now, we'll pass a fixed GameModule array with all games:
    @game_launcher = GameLauncher.new(
      [TicTacToe, TwentyOne, NumberGuesser],
      name
    )
  end

  def play
    loop do
      game_launcher.select_game
      game_launcher.play

      print 'Would you like to play another game? (Y/N)'
      play_again = gets.chomp
      break unless play_again.downcase == 'y'
    end

    # What else might we want to do when a player is done gaming for now?
  end

  private

  attr_reader :game_launcher
end

player_one = Player.new
# `player_one` is logged in and ready to start at this point! They can now
# select a game, play it, then select a different game if they wish with this
# simple `play` invocation:
player_one.play
