# ExCopter

```elixir
defmodule MyCopter do
  import ExCopter.Command.Client

  def demo do
    IO.puts "Taking off..."
    takeoff
    for 2000, fn -> end

    IO.puts "Spinning.."
    for 3500, fn -> spin_left 25 end

    IO.puts "Landing..."
    land
  end
end
```
