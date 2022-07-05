# frozen_string_literal: true

require_relative '09_deck_of_cards'

module CardHandRankComparable
  include Comparable

  # Override or merge in subclass.
  # Each key should:
  # - Be in order of top-level score.
  # - Point to methods that extend the top-level score with second-level scores
  #   and beyond. See `<=>` method for details.
  RANKING_METHODS = {
    'High card': :high_card
  }.freeze

  def initialize_card_hand_rank_comparable
    @hand_score = nil
  end

  def evaluate
    @hand_score = [14 + self.class::RANKING_METHODS.size]

    self.class::RANKING_METHODS.each do |name, method|
      return name.to_s if send(method)

      hand_score[0] -= 1
    end
  end

  # Ensure that scores are appended in comparison order.
  def <=>(other)
    hand_score <=> other.hand_score
  end

  protected

  def hand_score
    evaluate if @hand_score.nil?

    @hand_score
  end

  private

  attr_reader :cards, :count_data

  def deal(cards)
    @hand_score = nil
    @cards = []
    @cards.concat(cards)
    build_count_data
  end

  # => { count:
  #      { rank:
  #        { score_extension: Integer, cards: Array }
  #      }
  #     }
  def build_count_data
    rank_groups = cards.group_by(&:rank)
    @count_data = rank_groups.each_with_object({}) do |(rank, cards), data|
      data[cards.size] = {} if data[cards.size].nil?
      data[cards.size][rank] = { score_extension: cards.first.rank_value, cards: cards }
    end
  end

  def unique_ranks?
    cards.uniq(&:rank).size == cards.size
  end

  def high_card
    hand_score << cards.max.rank_value
  end
end

class PokerHand
  include CardHandRankComparable

  RANKING_METHODS = {
    'Royal flush': :royal_flush?,
    'Straight flush': :straight_flush?,
    'Four of a kind': :four_of_a_kind?,
    'Full house': :full_house?,
    'Flush': :flush?,
    'Straight': :straight?,
    'Three of a kind': :three_of_a_kind?,
    'Two pair': :two_pair?,
    'Pair': :pair?
  }.merge(CardHandRankComparable::RANKING_METHODS).freeze

  def initialize(deck)
    initialize_card_hand_rank_comparable
    @deck = deck
    deal
  end

  def print
    puts cards
  end

  private

  attr_reader :deck

  def deal
    super(deck.draw(5))
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
    four_data = count_data[4]
    return false unless four_data

    hand_score << four_data.values.first[:score_extension]

    true
  end

  # Full house: Three cards of one rank and two of another
  def full_house?
    three_data = count_data[3]
    two_data = count_data[2]
    return false unless three_data && two_data

    hand_score << three_data.values.first[:score_extension] \
                << two_data.values.first[:score_extension]

    true
  end

  # Five cards of the same suit
  def flush?
    return false unless cards.map(&:suit).uniq.size == 1

    hand_score << cards.max.rank_value

    true
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
    return false unless unique_ranks? && (card_max.rank_value - card_min.rank_value == 4)

    hand_score << cards.max.rank_value

    true
  end

  # Three of a kind: Three cards of the same rank
  def three_of_a_kind?
    three_data = count_data[3]
    return false unless three_data

    hand_score << three_data.values.first[:score_extension]

    true
  end

  # Two pair: Two cards of one rank and two cards of another
  def two_pair?
    return false unless count_data[2]&.count == 2

    pair_scores_reverse =
      count_data[2].values.map { |data| data[:score_extension] }.sort.reverse
    hand_score.concat(pair_scores_reverse)

    true
  end

  # One pair: Two cards of the same rank
  def pair?
    return false unless count_data[2]&.count == 1

    hand_score << count_data[2].values.first[:score_extension]

    true
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

hand_straight_flush_queen_high = PokerHand.new([
                                                 Card.new(8, 'Clubs'),
                                                 Card.new(9, 'Clubs'),
                                                 Card.new('Queen', 'Clubs'),
                                                 Card.new(10, 'Clubs'),
                                                 Card.new('Jack', 'Clubs')
                                               ])
puts hand_straight_flush_queen_high.evaluate == 'Straight flush'
puts hand_straight_flush_queen_high < hand_royal_flush

hand_straight_flush_nine_high = PokerHand.new([
                                                Card.new(5, 'Clubs'),
                                                Card.new(6, 'Clubs'),
                                                Card.new(9, 'Clubs'),
                                                Card.new(7, 'Clubs'),
                                                Card.new(8, 'Clubs')
                                              ])
puts hand_straight_flush_nine_high.evaluate == 'Straight flush'
puts hand_straight_flush_nine_high < hand_straight_flush_queen_high

hand_four_of_a_kind_six_high = PokerHand.new([
                                               Card.new(6, 'Diamonds'),
                                               Card.new(6, 'Hearts'),
                                               Card.new(5, 'Diamonds'),
                                               Card.new(6, 'Spades'),
                                               Card.new(6, 'Clubs')
                                             ])
puts hand_four_of_a_kind_six_high.evaluate == 'Four of a kind'
puts hand_four_of_a_kind_six_high < hand_straight_flush_nine_high

hand_four_of_a_kind_three_high = PokerHand.new([
                                                 Card.new(3, 'Hearts'),
                                                 Card.new(3, 'Clubs'),
                                                 Card.new(5, 'Diamonds'),
                                                 Card.new(3, 'Spades'),
                                                 Card.new(3, 'Diamonds')
                                               ])
puts hand_four_of_a_kind_three_high.evaluate == 'Four of a kind'
puts hand_four_of_a_kind_three_high < hand_four_of_a_kind_six_high

hand_full_house_three_fives_and_two_kings = PokerHand.new([
                                                            Card.new(5, 'Hearts'),
                                                            Card.new(5, 'Clubs'),
                                                            Card.new('King', 'Diamonds'),
                                                            Card.new(5, 'Spades'),
                                                            Card.new('King', 'Hearts')
                                                          ])
puts hand_full_house_three_fives_and_two_kings.evaluate == 'Full house'
puts hand_full_house_three_fives_and_two_kings < hand_four_of_a_kind_three_high

hand_full_house_three_fours_and_two_aces = PokerHand.new([
                                                           Card.new(4, 'Hearts'),
                                                           Card.new(4, 'Clubs'),
                                                           Card.new('Ace', 'Diamonds'),
                                                           Card.new(4, 'Spades'),
                                                           Card.new('Ace', 'Hearts')
                                                         ])
puts hand_full_house_three_fours_and_two_aces.evaluate == 'Full house'
puts hand_full_house_three_fours_and_two_aces < hand_full_house_three_fives_and_two_kings

hand_full_house_three_fours_and_two_fives = PokerHand.new([
                                                            Card.new(4, 'Hearts'),
                                                            Card.new(4, 'Clubs'),
                                                            Card.new(5, 'Diamonds'),
                                                            Card.new(4, 'Spades'),
                                                            Card.new(5, 'Hearts')
                                                          ])
puts hand_full_house_three_fours_and_two_fives.evaluate == 'Full house'
puts hand_full_house_three_fours_and_two_fives < hand_full_house_three_fours_and_two_aces

hand_flush_ace_high = PokerHand.new([
                                      Card.new(10, 'Hearts'),
                                      Card.new('Ace', 'Hearts'),
                                      Card.new(2, 'Hearts'),
                                      Card.new('King', 'Hearts'),
                                      Card.new(3, 'Hearts')
                                    ])
puts hand_flush_ace_high.evaluate == 'Flush'
puts hand_flush_ace_high < hand_full_house_three_fours_and_two_fives

hand_flush_ten_high = PokerHand.new([
                                      Card.new(10, 'Clubs'),
                                      Card.new(2, 'Clubs'),
                                      Card.new(9, 'Clubs'),
                                      Card.new(3, 'Clubs'),
                                      Card.new(8, 'Clubs')
                                    ])
puts hand_flush_ten_high.evaluate == 'Flush'
puts hand_flush_ten_high < hand_flush_ace_high

hand_straight_ace_high = PokerHand.new([
                                         Card.new('Queen', 'Clubs'),
                                         Card.new('King', 'Diamonds'),
                                         Card.new(10, 'Clubs'),
                                         Card.new('Ace', 'Hearts'),
                                         Card.new('Jack', 'Clubs')
                                       ])
puts hand_straight_ace_high.evaluate == 'Straight'
puts hand_straight_ace_high < hand_flush_ten_high

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

hand_king_clubs_high = PokerHand.new([
                                       Card.new(2, 'Hearts'),
                                       Card.new('King', 'Clubs'),
                                       Card.new(5, 'Diamonds'),
                                       Card.new(9, 'Spades'),
                                       Card.new(3, 'Diamonds')
                                     ])
puts hand_king_clubs_high.evaluate == 'High card'
puts hand_king_clubs_high < hand_ace_high

hand_king_hearts_high = PokerHand.new([
                                        Card.new(2, 'Hearts'),
                                        Card.new('King', 'Hearts'),
                                        Card.new(5, 'Diamonds'),
                                        Card.new(9, 'Spades'),
                                        Card.new(3, 'Diamonds')
                                      ])
puts hand_king_hearts_high == hand_king_clubs_high
