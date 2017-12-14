
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

    header = ["name", "price_usd", "24h_volume_usd",
    "percent_change_1h", "percent_change_24h", "percent_change_7d",
    "max_supply"]

    rows = Enum.map(b,
        fn row -> Enum.map(header,
            fn field ->
                v = Map.get(row, field)
                cond do
                    field == "24h_volume_usd" ->
                        {intVal, _} = Integer.parse(v)
                        r = intVal / 1000000
                        Float.to_string(r) <> "M"
                    field =~ "percent" ->
                        v <> "%"
                    true ->
                        v
                end
            end)
        end)

    TableRex.Table.new(Enum.take(rows, n), header)
        |> TableRex.Table.put_column_meta(0, color: :yellow)
        |> TableRex.Table.put_column_meta(1, color: :green)
        |> TableRex.Table.put_column_meta(2, color: :yellow)
        |> TableRex.Table.put_column_meta(3, color: :green)
        |> TableRex.Table.put_column_meta(4, color: :green)
        |> TableRex.Table.put_column_meta(5, color: :cyan)
        |> TableRex.Table.put_column_meta(6, color: :blue)
        |> TableRex.Table.render!
        |> IO.puts

  end
end
