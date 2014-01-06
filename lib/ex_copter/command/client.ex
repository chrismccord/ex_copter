defmodule ExCopter.Command.Client do

  def startup do
    :gen_server.cast :copter_server, :startup
  end

  def takeoff do
    :gen_server.cast :copter_server, :takeoff
  end

  def land do
    :gen_server.cast :copter_server, :land
  end

  def hover do
    :gen_server.cast :copter_server, :hover
  end

  def roll_left(percent) do
    :gen_server.cast :copter_server, {:move, :roll_left, percent}
  end

  def roll_right(percent) do
    :gen_server.cast :copter_server, {:move, :roll_right, percent}
  end

  def spin_left(percent) do
    :gen_server.cast :copter_server, {:move, :spin_left, percent}
  end

  def spin_right(percent) do
    :gen_server.cast :copter_server, {:move, :spin_right, percent}
  end

  def pitch_forward(percent) do
    :gen_server.cast :copter_server, {:move, :pitch_forward, percent}
  end

  def pitch_backward(percent) do
    :gen_server.cast :copter_server, {:move, :pitch_backward, percent}
  end

  def rise(percent) do
    :gen_server.cast :copter_server, {:move, :rise, percent}
  end

  def lower(percent) do
    :gen_server.cast :copter_server, {:move, :lower, percent}
  end

  def emergency_on! do
    :gen_server.cast :copter_server, :emergency_on
  end

  def emergency_off do
    :gen_server.cast :copter_server, :emergency_off
  end

  def for(milliseconds, func) do
    client = self
    pid = spawn fn -> do_repeat(client, func) end
    {:ok, timer} = :timer.send_interval(30, pid, :tick)
    :timer.send_after milliseconds, pid, :stop
    receive do
      :stop -> :ok
    end
    {:ok, :cancel} = :timer.cancel(timer)
  end

  def do_repeat(client, func) do
    receive do
      :stop -> client <- :stop
      :tick -> func.()
    end
    do_repeat client, func
  end
end
