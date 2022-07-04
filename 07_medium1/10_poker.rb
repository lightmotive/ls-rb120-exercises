# frozen_string_literal: true

require_relative '09_deck_of_cards'

class PokerHand
  def initialize(deck)
    @deck = deck
    deal
  end

  def print
    puts cards
  end

  def evaluate
    if royal_flush?
      'Royal flush'
    elsif straight_flush?
      'Straight flush'
    elsif four_of_a_kind?
      'Four of a kind'
    elsif full_house?
      'Full house'
    elsif flush?
      'Flush'
    elsif straight?
      'Straight'
    elsif three_of_a_kind?
      'Three of a kind'
    elsif two_pair?
      'Two pair'
    elsif pair?
      'Pair'
    else
      'High card'
    end
  end

  private

  attr_accessor :is_flush, :is_straight, :has_unique_ranks
  attr_reader :deck, :cards

  def deal
    @cards = []
    cards.concat(deck.draw(5))
    cards.sort!
  end

  def unique_ranks?
    has_unique_ranks \
    || (self.has_unique_ranks = (cards.uniq(&:rank).size == cards.size))
  end

  # A, K, Q, J, 10 of the same suit
  def royal_flush?
    cards.first.rank_value == 10 && flush? && straight?
  end

  # Five cards of the same suit in sequence
  def straight_flush?
    flush? && straight?
  end

  def four_of_a_kind?
    # Four of a kind: Four cards of the same rank and any one other card
  end

  def full_house?
    # Full house: Three cards of one rank and two of another
  end

  # Five cards of the same suit
  def flush?
    is_flush || (self.is_flush = (cards.map(&:suit).uniq.size == 1))
  end

  # Straight: Five cards in sequence (for example, 4, 5, 6, 7, 8)
  def straight?
    # This class currently only supports "Ace-high" logic where "Ace"
    # rank_value = 14.
    # If the program needs to support both Ace-high and Ace-low games,
    # update CardComparable#rank_value:
    # - Add an (ace_low = false) parameter.
    # - Update the method to subtract 13 from "Ace"'s default value.
    # - One would then need to update PokerHand's logic to check
    #   `hand.sort_by { |card| card.rank_value(false) }` wherever
    #   position-based rank value logic is used.
    return is_straight unless is_straight.nil?

    (self.is_straight =
       unique_ranks? \
       && (cards.last.rank_value - cards.first.rank_value == 4))
  end

  def three_of_a_kind?
    # Three of a kind: Three cards of the same rank
  end

  def two_pair?
    # Two pair: Two cards of one rank and two cards of another
  end

  def pair?
    # One pair: Two cards of the same rank
  end
end

# Tests:
puts '** Poker test results: **'

hand = PokerHand.new(Deck.new)
hand.print
puts hand.evaluate

# Danger danger danger: monkey patch for testing.
class Array
  alias draw shift
end

# Test that we can identify each PokerHand type.
hand = PokerHand.new([
                       Card.new(10, 'Hearts'),
                       Card.new('Ace', 'Hearts'),
                       Card.new('Queen', 'Hearts'),
                       Card.new('King', 'Hearts'),
                       Card.new('Jack', 'Hearts')
                     ])
puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([
                       Card.new(8, 'Clubs'),
                       Card.new(9, 'Clubs'),
                       Card.new('Queen', 'Clubs'),
                       Card.new(10, 'Clubs'),
                       Card.new('Jack', 'Clubs')
                     ])
puts hand.evaluate == 'Straight flush'

hand = PokerHand.new([
                       Card.new(3, 'Hearts'),
                       Card.new(3, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(3, 'Spades'),
                       Card.new(3, 'Diamonds')
                     ])
puts hand.evaluate == 'Four of a kind'

hand = PokerHand.new([
                       Card.new(3, 'Hearts'),
                       Card.new(3, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(3, 'Spades'),
                       Card.new(5, 'Hearts')
                     ])
puts hand.evaluate == 'Full house'

hand = PokerHand.new([
                       Card.new(10, 'Hearts'),
                       Card.new('Ace', 'Hearts'),
                       Card.new(2, 'Hearts'),
                       Card.new('King', 'Hearts'),
                       Card.new(3, 'Hearts')
                     ])
puts hand.evaluate == 'Flush'

hand = PokerHand.new([
                       Card.new(8, 'Clubs'),
                       Card.new(9, 'Diamonds'),
                       Card.new(10, 'Clubs'),
                       Card.new(7, 'Hearts'),
                       Card.new('Jack', 'Clubs')
                     ])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
                       Card.new('Queen', 'Clubs'),
                       Card.new('King', 'Diamonds'),
                       Card.new(10, 'Clubs'),
                       Card.new('Ace', 'Hearts'),
                       Card.new('Jack', 'Clubs')
                     ])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
                       Card.new(3, 'Hearts'),
                       Card.new(3, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(3, 'Spades'),
                       Card.new(6, 'Diamonds')
                     ])
puts hand.evaluate == 'Three of a kind'

hand = PokerHand.new([
                       Card.new(9, 'Hearts'),
                       Card.new(9, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(8, 'Spades'),
                       Card.new(5, 'Hearts')
                     ])
puts hand.evaluate == 'Two pair'

hand = PokerHand.new([
                       Card.new(2, 'Hearts'),
                       Card.new(9, 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(9, 'Spades'),
                       Card.new(3, 'Diamonds')
                     ])
puts hand.evaluate == 'Pair'

hand = PokerHand.new([
                       Card.new(2, 'Hearts'),
                       Card.new('King', 'Clubs'),
                       Card.new(5, 'Diamonds'),
                       Card.new(9, 'Spades'),
                       Card.new(3, 'Diamonds')
                     ])
puts hand.evaluate == 'High card'
