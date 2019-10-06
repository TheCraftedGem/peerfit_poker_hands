defmodule PeerfitPokerHands.Parser do

  def parse(filename) do
    File.stream!(filename)
    |> Enum.map(fn line -> String.split_at(line, 15) end)
    |> Enum.map(fn x -> Tuple.to_list(x) end)
    |> Enum.map(fn [string_1, string_2] -> [String.split(string_1, " ", trim: true), String.replace(string_2, "\n", "") |> String.split(" ", trim: true)] end)
  end
end
