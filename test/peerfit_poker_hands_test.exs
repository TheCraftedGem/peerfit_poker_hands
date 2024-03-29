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
    player_1 = PeerfitPokerHands.hand(["2D", "2H", "2S", "8C", "KS"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "9D", "8H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["4D", "4H", "9H", "8C", "KS"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "3C", "8H", "TS"])
    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "straight wins against 3 of a kind" do
    player_1 = PeerfitPokerHands.hand(["3D", "2H", "4S", "6C", "5S"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "3D", "8H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["5D", "5H", "5H", "7C", "KS"])
    player_2 = PeerfitPokerHands.hand(["4S", "3D", "5C", "6H", "7S"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "flush wins against straight" do
    player_1 = PeerfitPokerHands.hand(["3D", "2H", "4S", "6C", "5S"])
    player_2 = PeerfitPokerHands.hand(["3S", "4S", "6S", "7S", "TS"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["2D", "5D", "6D", "7D", "KD"])
    player_2 = PeerfitPokerHands.hand(["4S", "3D", "5C", "6H", "7S"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "full house wins against flush" do
    player_1 = PeerfitPokerHands.hand(["3D", "4D", "6D", "TD", "AD"])
    player_2 = PeerfitPokerHands.hand(["3H", "3S", "6S", "6H", "6D"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["2D", "2H", "6D", "6H", "6C"])
    player_2 = PeerfitPokerHands.hand(["4S", "3D", "5C", "6H", "7S"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "hand with 4 of a kind wins against fullhouse" do
    player_1 = PeerfitPokerHands.hand(["2D", "2H", "2S", "2C", "KS"])
    player_2 = PeerfitPokerHands.hand(["3H", "3S", "6S", "6H", "6D"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["3H", "3S", "6S", "6H", "6D"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "3C", "3H", "TS"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "straight flush beats 4 of a kind" do
    player_1 = PeerfitPokerHands.hand(["2D", "3D", "4D", "5D", "6D"])
    player_2 = PeerfitPokerHands.hand(["3S", "3D", "3C", "3H", "TS"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["4D", "4H", "4H", "4C", "KS"])
    player_2 = PeerfitPokerHands.hand(["6S", "7S", "8S", "9S", "TS"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "Royal flush beats straight flush" do
    player_1 = PeerfitPokerHands.hand(["AD", "TD", "JD", "QD", "KD"])
    player_2 = PeerfitPokerHands.hand(["2D", "3D", "4D", "5D", "6D"])

    assert "Player 1 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)

    player_1 = PeerfitPokerHands.hand(["6S", "7S", "8S", "9S", "TS"])
    player_2 = PeerfitPokerHands.hand(["AS", "TS", "JS", "QS", "KS"])

    assert "Player 2 Wins!" == PeerfitPokerHands.evaluate(player_1, player_2)
  end

  test "player 1 score is tracked from games in text file" do
    # This is the first attempt to score player before handling all ties and sad paths
    PeerfitPokerHands.player_1_total_wins("poker.txt") == 378
  end


end
