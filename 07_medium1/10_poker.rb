# frozen_string_literal: true

require_relative '09_deck_of_cards'

module Cards
  private

  attr_reader :cards

  def deal(cards)
    @cards = []
    @cards.concat(cards)
  end

  def unique_ranks?
    cards.uniq(&:rank).size == cards.size
  end
end

module CardHandRankComparable
  include Cards
  include Comparable

  # Override or merge in subclass.
  # Each key should:
  # - Be in order of top-level score.
  # - Point to methods that extend the top-level score with second-level scores
  #   and beyond. See `<=>` method for details.
  RANKING_METHODS = {
    'High card': :high_card
  }.freeze

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

  attr_reader :count_data

  def deal(cards)
    super
    @hand_score = nil
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
