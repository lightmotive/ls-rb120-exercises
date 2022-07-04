# frozen_string_literal: true

require_relative '09_deck_of_cards'

class PokerHand
  def initialize(deck); end

  def print; end

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

  def royal_flush?; end

  def straight_flush?; end

  def four_of_a_kind?; end

  def full_house?; end

  def flush?; end

  def straight?; end

  def three_of_a_kind?; end

  def two_pair?; end

  def pair?; end
end

# Tests:
puts '** Poker test results: **'

hand = PokerHand.new(Deck.new)
hand.print
puts hand.evaluate

# Danger danger danger: monkey
# patching for testing purposes.
class Array
  alias draw pop
end

# Test that we can identify each PokerHand type.
hand = PokerHand.new([
                       Card.new(10,      'Hearts'),
                       Card.new('Ace',   'Hearts'),
                       Card.new('Queen', 'Hearts'),
                       Card.new('King',  'Hearts'),
                       Card.new('Jack',  'Hearts')
                     ])
puts hand.evaluate == 'Royal flush'

hand = PokerHand.new([
                       Card.new(8,       'Clubs'),
                       Card.new(9,       'Clubs'),
                       Card.new('Queen', 'Clubs'),
                       Card.new(10,      'Clubs'),
                       Card.new('Jack',  'Clubs')
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
                       Card.new(9,      'Diamonds'),
                       Card.new(10,     'Clubs'),
                       Card.new(7,      'Hearts'),
                       Card.new('Jack', 'Clubs')
                     ])
puts hand.evaluate == 'Straight'

hand = PokerHand.new([
                       Card.new('Queen', 'Clubs'),
                       Card.new('King',  'Diamonds'),
                       Card.new(10,      'Clubs'),
                       Card.new('Ace',   'Hearts'),
                       Card.new('Jack',  'Clubs')
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
                       Card.new(5,      'Diamonds'),
                       Card.new(9,      'Spades'),
                       Card.new(3,      'Diamonds')
                     ])
puts hand.evaluate == 'High card'
