
defmodule Commandline.CLI do
  def main(args) do
    {opts, _, _} = OptionParser.parse(args, switches: [file: :string], aliases: [f: :file])
    IO.inspect opts

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
                        Float.to_string(r) <> " M"
                    field =~ "percent" ->
                        v <> "%"
                    true ->
                        v
                end
            end)
        end)

    TableRex.Table.new(Enum.take(rows, 10), header)
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
