defmodule PeerfitPokerHandsTest do
  use ExUnit.Case
  doctest PeerfitPokerHands

  test "evaluate hands for highest value hand" do

    player_1 = ["5H", "5C", "6S", "7S", "KD"]
    player_2 = ["2C", "3S", "8S", "8D", "TD"]

    player_1_second_hand = ["5D", "8C", "9S", "JS", "AC"]
    player_2_second_hand = ["2C", "5C", "7D", "8S", "QH"]

    assert PeerfitPokerHands.evaluate(player_1, player_2) == "Player 2 Wins!"
    assert PeerfitPokerHands.evaluate(player_1_second_hand, player_2_second_hand) == "Player 1 Wins"
    # Possible a function to call after a couple hands and check the score count
  end
end
