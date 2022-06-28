# frozen_string_literal: true

class GuessingGame
  GUESS_RESULT_MESSAGES = { high: 'Your guess is too high.',
                            low: 'Your guess is too low.',
                            match: "That's the number!" }.freeze

  GUESS_RESULT_TO_GAME_RESULT = { high: :lose, low: :lose, match: :win }.freeze

  GAME_RESULT_MESSAGES = { win: 'You won!',
                           lose: 'You have no more guesses. You lost!' }.freeze

  def initialize(range: (1..100))
    @range = range
    update_max_guesses
    @number = nil
  end

  def play
    reset

    puts game_result_message(play_guess)
  end

  private

  attr_accessor :range, :number
  attr_reader :max_guesses

  def update_max_guesses
    @max_guesses = Math.log2(range.size).to_i + 1
  end

  def reset
    self.number = rand(range)
  end

  def play_guess
    max_guesses.downto(1) do |guesses_remaining|
      puts "\nYou have #{guesses_remaining} #{guesses_remaining > 1 ? 'guesses' : 'guess'} remaining."
      guess = prompt_guess
      result = guess_result(guess)
      puts guess_result_message(result)
      break GUESS_RESULT_TO_GAME_RESULT[result] if result == :match || guesses_remaining == 1
    end
  end

  def prompt_guess
    loop do
      print "Enter a number between #{range.begin} and #{range.end}: "
      guess = gets.chomp.to_i
      break guess if range.cover?(guess)

      print 'Invalid guess. '
    end
  end

  def guess_result(guess)
    case guess <=> number
    when 0 then :match
    when -1 then :low
    when 1 then :high
    end
  end

  def game_result_message(game_result)
    "\n#{GAME_RESULT_MESSAGES[game_result]}"
  end

  def guess_result_message(result)
    GUESS_RESULT_MESSAGES[result]
  end
end

# Lesson reinforced: don't spike until the problem has been processed logically.
# Extract nouns and verbs, writing states and behaviors that are easy to follow.
# Let that guide the design.
# When a specific *set* of results is expected, design the following:
# - A hash that stores data, e.g., strings or actions.
# - A method that returns symbols/keys to look up that data.

game = GuessingGame.new(range: 501..1500)
game.play

# You have 7 guesses remaining.
# Enter a number between 1 and 100: 104
# Invalid guess. Enter a number between 1 and 100: 50
# Your guess is too low.
#
# You have 6 guesses remaining.
# Enter a number between 1 and 100: 75
# Your guess is too low.
#
# You have 5 guesses remaining.
# Enter a number between 1 and 100: 85
# Your guess is too high.
#
# You have 4 guesses remaining.
# Enter a number between 1 and 100: 0
# Invalid guess. Enter a number between 1 and 100: 80
#
# You have 3 guesses remaining.
# Enter a number between 1 and 100: 81
# That's the number!
#
# You won!

game.play

# You have 7 guesses remaining.
# Enter a number between 1 and 100: 50
# Your guess is too high.
#
# You have 6 guesses remaining.
# Enter a number between 1 and 100: 25
# Your guess is too low.
#
# You have 5 guesses remaining.
# Enter a number between 1 and 100: 37
# Your guess is too high.
#
# You have 4 guesses remaining.
# Enter a number between 1 and 100: 31
# Your guess is too low.
#
# You have 3 guesses remaining.
# Enter a number between 1 and 100: 34
# Your guess is too high.
#
# You have 2 guesses remaining.
# Enter a number between 1 and 100: 32
# Your guess is too low.
#
# You have 1 guesses remaining.
# Enter a number between 1 and 100: 32
# Your guess is too low.
#
# You have no more guesses. You lost!
