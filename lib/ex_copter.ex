defmodule ExCopter do
  use Application.Behaviour

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    ExCopter.Supervisor.start_link
  end

  def demo do
    import ExCopter.Command.Client

    IO.puts "Taking off..."
    takeoff
    for 2000, fn -> end

    IO.puts "Spinning.."
    for 3500, fn -> spin_left 25 end

    IO.puts "Landing..."
    land
  end
end
