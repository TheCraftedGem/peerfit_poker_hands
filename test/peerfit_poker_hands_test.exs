defmodule PeerfitPokerHandsTest do
  use ExUnit.Case
  doctest PeerfitPokerHands

  test "evaluate hands for highest value hand with pairs" do

    player_1 = ["5H", "5C", "6S", "7S", "KD"]
    player_2 = ["2C", "3S", "8S", "8D", "TD"]

    player_1_second_hand = ["5D", "8C", "9S", "JS", "AC"]
    player_2_second_hand = ["2C", "5C", "7D", "8S", "QH"]

    assert PeerfitPokerHands.evaluate(player_1, player_2) == "Player 2 Wins!"
    assert PeerfitPokerHands.evaluate(player_1_second_hand, player_2_second_hand) == "Player 1 Wins!"
    # Possible a function to call after a couple hands and check the score count
  end


  test "hand with high card wins" do
    player_1 = PeerfitPokerHands.hand(["2D", "3H", "9H", "8C", "KS"])
    player_2 = PeerfitPokerHands.hand(["2S", "3D", "9D", "8H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "hand with pair wins against no pair" do
    player_1 = PeerfitPokerHands.hand(["2D", "2H", "3H", "4C", "KS"])
    player_2 = PeerfitPokerHands.hand(["2S", "4D", "9D", "8H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["4D", "2H", "9H", "8C", "KS"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "9D", "8H", "TS"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "hand with 3 of a kind wins against pair" do
    black = PeerfitPokerHands.hand(["2D", "2H", "2S", "8C", "KS"])
    white = PeerfitPokerHands.hand(["3S", "3D", "9D", "8H", "TS"])

    black_2 = PeerfitPokerHands.hand(["4D", "4H", "9H", "8C", "KS"])
    white_2 = PeerfitPokerHands.hand(["3S", "3D", "3C", "8H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(black, white)
    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(black_2, white_2)
  end
end
