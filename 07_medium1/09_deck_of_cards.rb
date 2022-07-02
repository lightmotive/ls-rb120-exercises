# frozen_string_literal: true

require_relative '08_highest_and_lowest_ranking_cards'

class Deck
  RANKS = ((2..10).to_a + %w[Jack Queen King Ace]).freeze
  SUITS = %w[Hearts Clubs Diamonds Spades].freeze
end

# Examples/tests
deck = Deck.new
drawn = []
52.times { drawn << deck.draw }
drawn.count { |card| card.rank == 5 } == 4
drawn.count { |card| card.suit == 'Hearts' } == 13

drawn2 = []
52.times { drawn2 << deck.draw }
drawn != drawn2 # Almost always.
