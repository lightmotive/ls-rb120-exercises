# frozen_string_literal: true

module CardComparable
  include Comparable

  RANK_VALUES = { 'Jack' => 11, 'Queen' => 12, 'King' => 13, 'Ace' => 14 }.freeze
  SUIT_VALUES = { 'Diamonds' => 1, 'Clubs' => 1, 'Hearts' => 1, 'Spades' => 1 }.freeze

  def <=>(other)
    rank_value = self.rank_value
    other_rank_value = other.rank_value
    return suit_value <=> other.suit_value if rank_value == other_rank_value

    rank_value <=> other_rank_value
  end

  def rank_value
    self.class::RANK_VALUES.fetch(rank, rank)
  end

  def suit_value
    self.class::SUIT_VALUES.fetch(suit)
  end
end

class Card
  include CardComparable
  # To change value behavior, simply include `CardComparable` instead.

  attr_reader :rank, :suit

  def initialize(rank, suit)
    @rank = rank
    @suit = suit
  end

  def to_s
    "#{rank} of #{suit}"
  end
end

# Examples & Tests

cards = [Card.new(2, 'Hearts'),
         Card.new(10, 'Diamonds'),
         Card.new('Ace', 'Clubs')]
puts cards.map(&:to_s) == ['2 of Hearts', '10 of Diamonds', 'Ace of Clubs']
puts cards.min == Card.new(2, 'Hearts')
puts cards.max == Card.new('Ace', 'Clubs')

cards = [Card.new(5, 'Hearts')]
puts cards.min == Card.new(5, 'Hearts')
puts cards.max == Card.new(5, 'Hearts')

cards = [Card.new(4, 'Hearts'),
         Card.new(4, 'Diamonds'),
         Card.new(10, 'Clubs')]
puts cards.min.rank == 4
puts cards.max == Card.new(10, 'Clubs')

cards = [Card.new(7, 'Diamonds'),
         Card.new('Jack', 'Diamonds'),
         Card.new('Jack', 'Spades')]
puts cards.min == Card.new(7, 'Diamonds')
puts cards.max.rank == 'Jack'

cards = [Card.new(8, 'Diamonds'),
         Card.new(8, 'Clubs'),
         Card.new(8, 'Spades')]
puts cards.min.rank == 8
puts cards.max.rank == 8

# Further exploration:
module CardComparableFE
  include CardComparable

  SUIT_VALUES = { 'Diamonds' => 1, 'Clubs' => 2, 'Hearts' => 3, 'Spades' => 4 }.freeze
end

class CardFE < Card
  include CardComparableFE
end

spades4 = CardFE.new(4, 'Spades')
hearts4 = CardFE.new(4, 'Hearts')
clubs4 = CardFE.new(4, 'Clubs')
diamonds4 = CardFE.new(4, 'Diamonds')
diamonds5 = CardFE.new(5, 'Diamonds')

p spades4 > hearts4
p hearts4 > clubs4
p clubs4 > diamonds4
p diamonds5 > spades4
