# frozen_string_literal: true

puts "** `Cards` test results: **\n" # For exercise purposes only
require_relative '08_highest_and_lowest_ranking_cards'

class Deck
  include Enumerable

  RANKS = ((2..10).to_a + %w[Jack Queen King Ace]).freeze
  SUITS = %w[Hearts Clubs Diamonds Spades].freeze

  def initialize
    reset
  end

  def draw(count = 1)
    card_set = draw_set(count)
    return card_set.first if card_set.size == 1

    card_set
  end

  def each(&block)
    cards.each(&block)
  end

  private

  attr_accessor :cards

  def draw_set(count)
    card_set = []

    while count.positive?
      reset if cards.empty?

      draw_count = count
      draw_count = cards.size if draw_count > cards.size

      card_set.concat(cards.shift(draw_count))
      count -= draw_count
    end

    card_set
  end

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
drawn = deck.draw(52)
p(drawn.count { |card| card.rank == 5 } == 4)
p(drawn.count { |card| card.suit == 'Hearts' } == 13)

drawn2 = deck.draw(52)
p(drawn != drawn2) # Almost always.

drawn4 = deck.draw(105)
p(drawn4.count { |card| card.rank == 6 } == 8)
p(drawn4.count { |card| card.suit == 'Spades' } == 26)

drawn4 = deck.draw(105)
p drawn4.size == 105
