require IEx
defmodule PeerfitPokerHands.Parser do

  def parse(filename) do
    x =  File.stream!(filename)
    |> Enum.map(fn line -> String.split_at(line, 15) end)
    |> Enum.map(fn x -> Tuple.to_list(x) end)
    |> Enum.map(fn [string_1, string_2] -> [String.split(string_1, " ", trim: true), String.replace(string_2, "\n", "") |> String.split(" ", trim: true)] end)
    IEx.pry
  end
end

#  Enum.take_while(tuple_list, fn tuple -> )
# Enum.filter(tuple_list, fn tuple -> Enum.map(Tuple.to_list(tuple), fn string -> String.starts_with?(string, "//") end) end)
