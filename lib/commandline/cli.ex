
defmodule Commandline.CLI do

  def zero_pad(number, amount \\ 2) do
     number
       |> Integer.to_string
       |> String.pad_leading(amount, ["0"])
  end

  defp now_to_string() do
      {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
      "update time : #{year}.#{month |> zero_pad}.#{day} #{hour |> zero_pad}:#{minute |> zero_pad}:#{second |> zero_pad}"
  end

  def main(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [num: :integer], aliases: [n: :num])

    opts = Keyword.merge([num: 10], opts) |> Enum.into(%{})

    n = opts[:num]

    IO.puts now_to_string()

    response = HTTPotion.get("https://api.coinmarketcap.com/v1/ticker/")

    b = Poison.decode!(response.body)

    mapping = ["rank": "rank", "name": "name", "price": "price_usd", "vol_24h": "24h_volume_usd",
        "1h change": "percent_change_1h", "24h change": "percent_change_24h",
        "week change": "percent_change_7d", "cap": "max_supply"]

    rows = Enum.map(b,
        fn row -> Enum.map(Keyword.values(mapping),
            fn field ->
                cond do
                    field == "24h_volume_usd" ->
                        {intVal, _} = Integer.parse(Map.get(row, field))
                        r = intVal / 1000000
                        Float.to_string(r) <> "M"
                    field =~ "percent" ->
                        Map.get(row, field) <> "%"
                    true ->
                        Map.get(row, field)
                end
            end)
        end)

    TableRex.Table.new(Enum.take(rows, n), Keyword.keys(mapping))
        |> TableRex.Table.put_column_meta(0, color: :blue)
        |> TableRex.Table.put_column_meta(1, color: :green)
        |> TableRex.Table.put_column_meta(2, color: :yellow)
        |> TableRex.Table.put_column_meta(3, color: :green)
        |> TableRex.Table.put_column_meta(4, color: :green)
        |> TableRex.Table.put_column_meta(5, color: :cyan)
        |> TableRex.Table.put_column_meta(6, color: :blue)
        |> TableRex.Table.put_column_meta(7, color: :blue)
        |> TableRex.Table.render!
        |> IO.puts

  end
end
