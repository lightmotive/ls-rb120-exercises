# frozen_string_literal: true

require_relative '10_poker'

# Tests:
puts '** Poker test results: **'

# Test-specific monkey patch:
class Array
  alias draw shift
end
# Refinements are not suitable here because they're lexically scoped.
# "When control is transferred outside the scope, the refinement is deactivated.
#   This means that if you require or load a file or call a method that is
#   defined outside the current scope the refinement will be deactivated..."
#   - Source: https://devdocs.io/ruby~3/syntax/refinements_rdoc#:~:text=foo%20in%20M%22-,scope,-You%20may%20activate
# That shouldn't be a problem when used like this because test files are not
# included in distributed programs/packages.

hand = PokerHand.new(Deck.new)
hand.print
puts hand.evaluate

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
