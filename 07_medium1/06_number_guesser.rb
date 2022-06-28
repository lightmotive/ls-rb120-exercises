# frozen_string_literal: true

class InvalidGuess < StandardError; end

class GuessingGame
  NUMBER_MIN = 1
  NUMBER_MAX = 100

  def play
    reset

    loop do
      break display_lost if guesses_remaining.zero?

      prompt_guess
      break display_won if guess_match?

      display_hint unless guesses_remaining.zero?
    end
  end

  private

  attr_accessor :number, :guesses_remaining, :current_guess

  def reset
    puts "\n"
    self.number = rand(NUMBER_MIN..NUMBER_MAX)
    self.guesses_remaining = 7
    self.current_guess = nil
  end

  def prompt_guess
    puts "You have #{guesses_remaining} guesses remaining."
    loop do
      print "Enter a number between #{NUMBER_MIN} and #{NUMBER_MAX}: "
      self.current_guess = input_to_i(gets.chomp)
      validate_guess
      self.guesses_remaining -= 1
      break
    rescue InvalidGuess
      print 'Invalid guess. '
    end
  end

  def input_to_i(input)
    # Normally, one would further validate the input as an integer using a
    # validation library and raise an InvalidInput exception; skipping that
    # because it isn't explicitly required for this exercise.
    input.to_i
  end

  def validate_guess
    raise InvalidGuess unless current_guess.between?(NUMBER_MIN, NUMBER_MAX)
  end

  def guess_match?
    current_guess == number
  end

  def display_hint
    message = 'Your guess is too low.' if current_guess < number
    message = 'Your guess is too high.' if current_guess > number

    puts "#{message}\n\n"
  end

  def display_won
    puts "That's the number!\n\nYou won!"
  end

  def display_lost
    puts "\nYou have no more guesses. You lost!"
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
