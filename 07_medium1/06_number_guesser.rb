# frozen_string_literal: true

class GuessingGame
  def initialize
    @number = rand(1..100)
    @guesses_remaining = 7
  end

  def play
    # loop to get input and check guesses
    #   - Use methods to check, e.g., `guess_correct = match?`
    #   - Display results
    #   - `break if guess_correct`
  end

  private

  attr_reader :number, :guesses_remaining

  def match?(guess)
    # compare guess with `number`
  end

  def display_status
    # ...
  end

  def display_won
    # ...
  end

  def display_lost
    # ...
  end
end

game = GuessingGame.new
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
