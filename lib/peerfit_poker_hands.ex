require IEx
defmodule PeerfitPokerHands do
  # TODOS
  #   Load Poker.txt File And Parse Into 2 Hands
  #     Create Parser Module To Handle File
  #   Use Genserver To Keep Track Of Score And Return Score For Individual Player
  #     Otherwise use a reduce to keep track instead
  #   Pattern Match Individual winning hands
  # Questions
  #  No validations?

  def values(), do:
    %{"2" => 2, "3" => 3,
      "4" => 4, "5" => 5,
      "6" => 6, "7" => 7,
      "8" => 8, "9" => 9,
      "T" => 10, "J" => 11,
      "Q" => 12, "K" => 13,
      "A" => 14}

  def suits(), do: %{"S" => 10, "D" => 20, "C" => 30, "H" => 40}

  def hand(hand), do: hand

  def valid_hand?(hand), do: card_count(hand) == 5 && all_valid_cards?(hand)

  def card_count(hand), do: Enum.count(hand)

  def all_valid_cards?(hand), do: Enum.all?(hand, fn x -> valid_card?(x) == true end)

  def valid_card?(card) do
    case Enum.count(convert(card)) do
      2 -> valid_value?(Enum.at(convert(card), 0)) && valid_suit?(Enum.at(convert(card), -1))
      3 -> valid_value?("#{Enum.at(PeerfitPokerHands.convert(card), 0)}#{Enum.at(PeerfitPokerHands.convert(card), 1)}")
        && valid_suit?(Enum.at(convert(card), -1))
      _ -> false
    end
  end

  def valid_value?("10") do
    true
  end

  def valid_value?(value) do
    Enum.any?(Map.keys(values()), fn x -> x == value end)
  end

  def valid_suit?(suit) do
    Enum.any?(Map.keys(suits()), fn x -> x == suit end)
  end

  def convert(card) do
    String.codepoints(card)
  end

  def convert_ten(suit) do
    ["10", suit]
  end

  def split_hand(hand) do
    Enum.map(hand, fn x ->
      case Enum.count(convert(x)) do
        2 -> convert(x)
        _ -> convert_ten(Enum.at(convert(x), -1))
      end
    end)
  end

  def group_by_values(hand) do
    split_hand(hand)
    |> Enum.group_by(fn x -> values()[Enum.at(x, 0)]  end)
    |> Enum.into(%{})
  end

  def pair_count(hand) do
    group_by_values(hand)
    |> Enum.filter(fn {_k, v} -> Enum.count(v) == 2 end)
    |> Enum.map(fn x -> Tuple.to_list(x) end)
    |> List.flatten
    |> List.delete_at(0)
    |> Enum.count
    |> div(4)
  end

  def three_count(hand) do
    Enum.max_by(group_by_values(hand), fn x -> tuple_size(x) end)
    |> Tuple.to_list
    |> List.flatten
    |> List.delete_at(0)
    |> Enum.count
    |> div(6)
  end

  def no_pairs?(hand) do
    with true <- valid_hand?(hand) do
      group_by_values(hand)
      |> Map.values
      |> Enum.all?(fn x -> Enum.count(x) == 1 end)
    end
  end

  def pairs?(hand) do
    with true <- valid_hand?(hand) do
      group_by_values(hand)
      |>Map.values
      |>Enum.any?(fn x -> Enum.count(x) == 2 end)
    end
  end

  def three_of_a_kind?(hand) do
    with true <- valid_hand?(hand) do
      group_by_values(hand)
      |>Map.values
      |>Enum.any?(fn x -> Enum.count(x) == 3 end)
    end
  end

  def evaluate_pair_ties(player_1, player_2) do
    pair_value_of_player_1 = group_by_values(player_1)
                              |> Enum.filter(fn {_k, v} -> Enum.count(v) == 2 end)
                              |> Enum.map(fn x -> Tuple.to_list(x) end)
                              |> List.flatten
                              |> Enum.at(0)
    pair_value_of_player_2 = group_by_values(player_2)
                              |> Enum.filter(fn {_k, v} -> Enum.count(v) == 2 end)
                              |> Enum.map(fn x -> Tuple.to_list(x) end)
                              |> List.flatten
                              |> Enum.at(0)

    case pair_value_of_player_1 == pair_value_of_player_2 do
      true -> evaluate_high_card(player_1, player_2)
      false ->
        case pair_value_of_player_1 > pair_value_of_player_2 do
          true ->
            "Player 1 Wins!"
          false ->
            "Player 2 Wins!"
        end
    end
  end

  def evaluate(hand_1, hand_2) do
    with true <- three_of_a_kind?(hand_1) || three_of_a_kind?(hand_2) do evaluate_three_of_a_kind(hand_1, hand_2) end ||
    with true <- pairs?(hand_1) && pairs?(hand_2) do evaluate_pair_ties(hand_1, hand_2) end ||
    with true <- pairs?(hand_1) || pairs?(hand_2) do evaluate_pairs(hand_1, hand_2) end ||
    with true <- no_pairs?(hand_1) && no_pairs?(hand_2), do: evaluate_high_card(hand_1, hand_2)
  end

  def evaluate_high_card(hand_1, hand_2)  do
    case Enum.max(group_by_values(hand_1)) > Enum.max(group_by_values(hand_2))  do
      true  -> "Player 1 Wins!"
      false -> "Player 2 Wins!"
    end
  end

  def evaluate_three_of_a_kind(hand_1, hand_2)  do
    case three_count(hand_1) > three_count(hand_2)  do
      true  -> "Player 1 Wins!"
      false -> "Player 2 Wins!"
    end
  end


  def evaluate_pairs(player_1, player_2) do
    case pair_count(player_1) > pair_count(player_2) do
      true  -> "Player 1 Wins!"
      false -> "Player 2 Wins!"
    end
  end
end
