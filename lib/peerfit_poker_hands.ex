require IEx
defmodule PeerfitPokerHands do
  # TODOS
  #   Load Poker.txt File And Parse Into 2 Hands
  #     Create Parser Module To Handle File
        # User File.stream!(filename)
  #   Use Genserver To Keep Track Of Score And Return Score For Individual Player
  #     Otherwise use a reduce to keep track instead
  #   Pattern Match Individual winning hands
  #   Refactor:
  #     Move Validations To Seperate Modules Along With Other Stuff
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

  def four_count(hand) do
    Enum.max_by(group_by_values(hand), fn x -> tuple_size(x) end)
    |> Tuple.to_list
    |> List.flatten
    |> List.delete_at(0)
    |> Enum.count
    |> div(8)
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

  def four_of_a_kind?(hand) do
    with true <- valid_hand?(hand) do
      group_by_values(hand)
      |>Map.values
      |>Enum.any?(fn x -> Enum.count(x) == 4 end)
    end
  end

  def straight?(hand) do
    #  Compare Range From Cards To Correct Range
    {first, _} = group_by_values(hand)
      |> Enum.fetch!(0)

    {last, _} = group_by_values(hand)
      |> Enum.fetch!(-1)

    Enum.all?(first..last, fn x -> group_by_values(hand)[x] end) &&
      (last - first) == 4
  end

  def check_flush?([{_, f}, {_, f}, {_, f}, {_, f}, {_, f}]), do: true
  def check_flush?(_), do: false

  def flush?(hand)  do
    group_by_values(hand)
    |> Map.values()
    |> Enum.map(fn x -> List.flatten(x)
        |> List.to_tuple() end)
    |> check_flush?()
  end

  def straight_value(hand) do
    group_by_values(hand)
    |> Enum.fetch!(-1)
  end

  def evaluate_pair_ties(player_1, player_2) do
    # Create helper function for these variables
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

  def check_full_house([{a, _, a, _}, {b, _, b, _, b, _}]), do: true
  def check_full_house([{a, _, a, _, a, _}, {b, _, b, _}]), do: true
  def check_full_house(_), do: false

  def full_house?(hand) do
    group_by_values(hand)
    |> Map.values()
    |> Enum.map(fn x -> List.flatten(x) |> List.to_tuple() end)
    |> check_full_house()
  end

  def straight_flush?(hand) do
    straight?(hand) && flush?(hand)
  end

  def check_royal_flush([{"A", "S"}, {"T", "S"}, {"J", "S"}, {"Q", "S"}, {"K", "S"}]), do: true
  def check_royal_flush([{"A", "C"}, {"T", "C"}, {"J", "C"}, {"Q", "C"}, {"K", "C"}  ]), do: true
  def check_royal_flush([{"A", "H"}, {"T", "H"}, {"J", "H"}, {"Q", "H"}, {"K", "H"}  ]), do: true
  def check_royal_flush([{"A", "D"}, {"T", "D"}, {"J", "D"}, {"Q", "D"}, {"K", "D"}  ]), do: true
  def check_royal_flush(_), do: false


  def royal_flush?(hand) do
    group_by_values(hand)
    |> Map.values()
    |> Enum.map(fn x -> List.flatten(x) |> List.to_tuple() end)
    |> check_royal_flush()
  end

  def evaluate(player_1, player_2) do
    # Royal Flush
    with true <- royal_flush?(player_1) || royal_flush?(player_2) do evaluate_royal_flush(player_1, player_2) end ||
    with true <- straight_flush?(player_1) || straight_flush?(player_2) do evaluate_straight_flush(player_1, player_2) end ||
    with true <- four_of_a_kind?(player_1) || four_of_a_kind?(player_2) do evaluate_four_of_a_kind(player_1, player_2) end ||
    with true <- full_house?(player_1) || full_house?(player_2) do evaluate_full_house(player_1, player_2) end ||
    with true <- flush?(player_1) || flush?(player_2) do evaluate_flush(player_1, player_2) end ||
    with true <- straight?(player_1) || straight?(player_2) do evaluate_straight_hand(player_1, player_2) end ||
    with true <- three_of_a_kind?(player_1) || three_of_a_kind?(player_2) do evaluate_three_of_a_kind(player_1, player_2) end ||
    with true <- pairs?(player_1) && pairs?(player_2) do evaluate_pair_ties(player_1, player_2) end ||
    with true <- pairs?(player_1) || pairs?(player_2) do evaluate_pairs(player_1, player_2) end ||
    with true <- no_pairs?(player_1) && no_pairs?(player_2), do: evaluate_high_card(player_1, player_2)
  end

  def evaluate_royal_flush(player_1, player_2) do
    case royal_flush?(player_1) && royal_flush?(player_2) do
      true  ->
        evaluate_high_card(player_1, player_2)
      false ->
        royal_flush_hand = Enum.filter([player_1, player_2], fn x -> royal_flush?(x) end)
        |> List.flatten()
        case royal_flush_hand == player_1 do
          true -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
    end

  end


  def evaluate_straight_flush(player_1, player_2) do
    case straight_flush?(player_1) && straight_flush?(player_2) do
      true  ->
        evaluate_high_card(player_1, player_2)
      false ->
        straight_flush_hand = Enum.filter([player_1, player_2], fn x -> straight_flush?(x) end)
        |> List.flatten()
        case straight_flush_hand == player_1 do
          true -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
    end
  end
  def evaluate_full_house(player_1, player_2) do
    case full_house?(player_1) && full_house?(player_2) do
      true  ->
        evaluate_high_card(player_1, player_2)
      false ->
        full_house_hand = Enum.filter([player_1, player_2], fn x -> full_house?(x) end)
        |> List.flatten()
        case full_house_hand == player_1 do
          true -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
    end
  end

  def evaluate_flush(player_1, player_2) do
    case flush?(player_1) && flush?(player_2) do
      true  ->
        evaluate_high_card(player_1, player_2)
      false ->
        flush_hand = Enum.filter([player_1, player_2], fn x -> flush?(x) end)
        |> List.flatten()
        case flush_hand == player_1 do
          true -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
    end
  end

  def evaluate_straight_hand(player_1, player_2) do
    case straight?(player_1) && straight?(player_2) do
      true  ->
        case straight_value(player_1) > straight_value(player_2) do
          true  -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
      false ->
        straight_hand = Enum.filter([player_1, player_2], fn x -> straight?(x) end)
        |> List.flatten()
        case straight_hand == player_1 do
          true -> "Player 1 Wins!"
          false -> "Player 2 Wins!"
        end
    end
  end

  def evaluate_four_of_a_kind(player_1, player_2) do
    case four_count(player_1) > four_count(player_2)  do
      true  -> "Player 1 Wins!"
      false -> "Player 2 Wins!"
    end
  end

  def evaluate_high_card(player_1, player_2)  do
    case Enum.max(group_by_values(player_1)) > Enum.max(group_by_values(player_2))  do
      true  -> "Player 1 Wins!"
      false -> "Player 2 Wins!"
    end
  end

  def evaluate_three_of_a_kind(player_1, player_2)  do
    case three_count(player_1) > three_count(player_2)  do
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
