# frozen_string_literal: true

puts "** `Cards` test results: **\n" # For exercise purposes only
require_relative '08_highest_and_lowest_ranking_cards'

class Deck
  RANKS = ((2..10).to_a + %w[Jack Queen King Ace]).freeze
  SUITS = %w[Hearts Clubs Diamonds Spades].freeze

  def initialize
    reset
  end

  def draw
    reset if cards.empty?

    cards.shift
  end

  private

  attr_accessor :cards

  def reset
    self.cards = SUITS.to_enum(:product, RANKS).map do |suit, rank|
      Card.new(rank, suit)
    end

    cards.shuffle!

    nil
  end
end

# Examples/tests
puts '** `Deck` test results: **' # For exercise purposes only
deck = Deck.new
drawn = []
52.times { drawn << deck.draw }
p(drawn.count { |card| card.rank == 5 } == 4)
p(drawn.count { |card| card.suit == 'Hearts' } == 13)

drawn2 = []
52.times { drawn2 << deck.draw }
p(drawn != drawn2) # Almost always.
