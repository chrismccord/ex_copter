# ExCopter
> Elixir client for the Parrot AR 2.0 Quadcopter

### Roadmap
- Improve docs
- Add Pid based client to support multiple drone connections
- Add NavData support for streaming copter data

The Client API is still in flux regarding scripting client commands, ie `for` syntax. Ideas are welcome on the issue tracker.

## Usage
```elixir
defmodule MyCopter do
  import ExCopter.Command.Client

  def demo do
    IO.puts "Taking off..."
    takeoff
    for 2000, fn -> end

    IO.puts "Spinning..."
    for 3500, fn -> spin_left 25 end

    IO.puts "Landing..."
    land
  end
end
```
