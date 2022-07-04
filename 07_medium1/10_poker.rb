# frozen_string_literal: true

require_relative '09_deck_of_cards'

class PokerHand
  include Comparable

  EVALUATION_METHODS = {
    'Royal flush': :royal_flush?,
    'Straight flush': :straight_flush?,
    'Four of a kind': :four_of_a_kind?,
    'Full house': :full_house?,
    'Flush': :flush?,
    'Straight': :straight?,
    'Three of a kind': :three_of_a_kind?,
    'Two pair': :two_pair?,
    'Pair': :pair?
  }.freeze

  def initialize(deck)
    @deck = deck
    deal
    @hand_value = nil
  end

  def print
    puts cards
  end

  def evaluate
    @hand_value = 14 + EVALUATION_METHODS.size

    EVALUATION_METHODS.each do |name, method|
      return name.to_s if send(method)

      @hand_value -= 1
    end

    'High card'
  end

  def <=>(other)
    hand_comparison = hand_value <=> other.hand_value
    return high_card_value <=> other.high_card_value if hand_comparison.zero?

    hand_comparison
  end

  protected

  def hand_value
    evaluate if @hand_value.nil?

    @hand_value
  end

  def high_card_value
    cards.max.rank_value
  end

  private

  attr_reader :deck, :cards

  def deal
    @cards = []
    cards.concat(deck.draw(5))
  end

  def unique_ranks?
    cards.uniq(&:rank).size == cards.size
  end

  # Array of rank-grouped card counts
  # Cache value for performance.
  def rank_group_sizes_sorted
    return @rank_group_sizes_sorted unless @rank_group_sizes_sorted.nil?

    @rank_group_sizes_sorted = cards.group_by(&:rank).values.map(&:size).sort
  end

  # A, K, Q, J, 10 of the same suit
  def royal_flush?
    cards.first.rank_value == 10 && flush? && straight?
  end

  # Five cards of the same suit in sequence
  def straight_flush?
    flush? && straight?
  end

  # Four of a kind: Four cards of the same rank and any one other card
  def four_of_a_kind?
    rank_group_sizes_sorted == [1, 4]
  end

  # Full house: Three cards of one rank and two of another
  def full_house?
    rank_group_sizes_sorted == [2, 3]
  end

  # Five cards of the same suit
  def flush?
    cards.map(&:suit).uniq.size == 1
  end

  # Straight: Five cards in sequence (for example, 4, 5, 6, 7, 8)
  def straight?
    # This class currently only supports "Ace-high" logic where "Ace"
    # rank_value = 14.
    # If the program needs to support both Ace-high and Ace-low games,
    # update CardComparable#rank_value so other games can reuse this logic:
    # - Add an (ace_low = false) parameter.
    # - Update the method to subtract 13 from "Ace"'s default value when
    #   `ace_low == true`.
    #     - Alternatively, reference two different `RANK_VALUES` hashes:
    #       - `RANK_VALUES_ACE_HIGH`, in which `'Ace' => 14`.
    #       - `RANK_VALUES_ACE_LOW`, in which `'Ace' => 1`.
    # - One would then need to update PokerHand's logic to check
    #   `hand.sort_by { |card| card.rank_value(false) }` wherever
    #   position-based rank value logic is used.
    card_min, card_max = cards.minmax
    unique_ranks? && (card_max.rank_value - card_min.rank_value == 4)
  end

  # Three of a kind: Three cards of the same rank
  def three_of_a_kind?
    rank_group_sizes_sorted == [1, 1, 3]
  end

  # Two pair: Two cards of one rank and two cards of another
  def two_pair?
    rank_group_sizes_sorted == [1, 2, 2]
  end

  # One pair: Two cards of the same rank
  def pair?
    rank_group_sizes_sorted == [1, 1, 1, 2]
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
hand_royal_flush = PokerHand.new([
                                   Card.new(10, 'Hearts'),
                                   Card.new('Ace', 'Hearts'),
                                   Card.new('Queen', 'Hearts'),
                                   Card.new('King', 'Hearts'),
                                   Card.new('Jack', 'Hearts')
                                 ])
puts hand_royal_flush.evaluate == 'Royal flush'

hand_straight_flush = PokerHand.new([
                                      Card.new(8, 'Clubs'),
                                      Card.new(9, 'Clubs'),
                                      Card.new('Queen', 'Clubs'),
                                      Card.new(10, 'Clubs'),
                                      Card.new('Jack', 'Clubs')
                                    ])
puts hand_straight_flush.evaluate == 'Straight flush'
puts hand_straight_flush < hand_royal_flush

hand_four_of_a_kind = PokerHand.new([
                                      Card.new(3, 'Hearts'),
                                      Card.new(3, 'Clubs'),
                                      Card.new(5, 'Diamonds'),
                                      Card.new(3, 'Spades'),
                                      Card.new(3, 'Diamonds')
                                    ])
puts hand_four_of_a_kind.evaluate == 'Four of a kind'
puts hand_four_of_a_kind < hand_straight_flush

hand_full_house = PokerHand.new([
                                  Card.new(3, 'Hearts'),
                                  Card.new(3, 'Clubs'),
                                  Card.new(5, 'Diamonds'),
                                  Card.new(3, 'Spades'),
                                  Card.new(5, 'Hearts')
                                ])
puts hand_full_house.evaluate == 'Full house'
puts hand_full_house < hand_four_of_a_kind

hand_flush = PokerHand.new([
                             Card.new(10, 'Hearts'),
                             Card.new('Ace', 'Hearts'),
                             Card.new(2, 'Hearts'),
                             Card.new('King', 'Hearts'),
                             Card.new(3, 'Hearts')
                           ])
puts hand_flush.evaluate == 'Flush'
puts hand_flush < hand_full_house

hand_straight_ace_high = PokerHand.new([
                                         Card.new('Queen', 'Clubs'),
                                         Card.new('King', 'Diamonds'),
                                         Card.new(10, 'Clubs'),
                                         Card.new('Ace', 'Hearts'),
                                         Card.new('Jack', 'Clubs')
                                       ])
puts hand_straight_ace_high.evaluate == 'Straight'
puts hand_straight_ace_high < hand_flush

hand_straight_jack_high = PokerHand.new([
                                          Card.new(8, 'Clubs'),
                                          Card.new(9, 'Diamonds'),
                                          Card.new(10, 'Clubs'),
                                          Card.new(7, 'Hearts'),
                                          Card.new('Jack', 'Clubs')
                                        ])
puts hand_straight_jack_high.evaluate == 'Straight'
puts hand_straight_jack_high < hand_straight_ace_high

hand_three_of_a_kind = PokerHand.new([
                                       Card.new(3, 'Hearts'),
                                       Card.new(3, 'Clubs'),
                                       Card.new(5, 'Diamonds'),
                                       Card.new(3, 'Spades'),
                                       Card.new(6, 'Diamonds')
                                     ])
puts hand_three_of_a_kind.evaluate == 'Three of a kind'
puts hand_three_of_a_kind < hand_straight_jack_high

hand_two_pair = PokerHand.new([
                                Card.new(9, 'Hearts'),
                                Card.new(9, 'Clubs'),
                                Card.new(5, 'Diamonds'),
                                Card.new(8, 'Spades'),
                                Card.new(5, 'Hearts')
                              ])
puts hand_two_pair.evaluate == 'Two pair'
puts hand_two_pair < hand_three_of_a_kind

hand_pair = PokerHand.new([
                            Card.new(2, 'Hearts'),
                            Card.new(9, 'Clubs'),
                            Card.new(5, 'Diamonds'),
                            Card.new(9, 'Spades'),
                            Card.new(3, 'Diamonds')
                          ])
puts hand_pair.evaluate == 'Pair'
puts hand_pair < hand_two_pair

hand_ace_high = PokerHand.new([
                                Card.new(2, 'Hearts'),
                                Card.new('Ace', 'Clubs'),
                                Card.new(5, 'Diamonds'),
                                Card.new(9, 'Spades'),
                                Card.new(3, 'Diamonds')
                              ])
puts hand_ace_high.evaluate == 'High card'
puts hand_ace_high < hand_pair

hand_king_high = PokerHand.new([
                                 Card.new(2, 'Hearts'),
                                 Card.new('King', 'Clubs'),
                                 Card.new(5, 'Diamonds'),
                                 Card.new(9, 'Spades'),
                                 Card.new(3, 'Diamonds')
                               ])
puts hand_king_high.evaluate == 'High card'
puts hand_king_high < hand_ace_high