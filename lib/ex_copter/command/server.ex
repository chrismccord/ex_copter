defmodule ExCopter.Command.Server do
  use GenServer.Behaviour
  alias ExCopter.Command.Builder

  defrecord Connection, ip: nil, port: nil, socket: nil, sequence_number: 1,
                        state: :resting, bufferred_commands: [], timer: nil

  @copter_port 5556
  @copter_ip "192.168.1.1"
  @flush_buffer_every_ms 30

  @movements [
    :roll_right,
    :spin_left,
    :spin_right,
    :pitch_forward,
    :pitch_backward,
    :rise,
    :lower,
  ]

  @doc """
  Starts the Command Server

  options - The Keyword List of options
    ip - The String copter IP
    port - The Integer copter UDP Port
  """
  def start_link(options // []) do
    :gen_server.start_link {:local, :copter_server}, __MODULE__, options, []
  end

  def init(options) do
    ip   = Keyword.get(options, :ip, @copter_ip)
    port = Keyword.get(options, :port, @copter_port)
    {:ok, socket} = :gen_udp.open(5557, [:binary, {:active, true}])
    {:ok, timer} = :timer.send_interval(@flush_buffer_every_ms, :flush)

    {:ok, Connection.new(
      socket: socket,
      ip: ip,
      port: port,
      timer: timer
    )}
  end

  def handle_cast(:takeoff, conn) do
    conn = buffer_command(conn, Builder.set_horizontal_plane(conn.sequence_number), state: :ready)
    conn = buffer_command(conn, Builder.takeoff(conn.sequence_number), state: :airborn)
    {:noreply, conn}
  end

  def handle_cast(:land, conn) do
    command = Builder.land(conn.sequence_number)
    {:noreply, buffer_command(conn, command, state: :landing)}
  end

  def handle_cast(:hover, conn) do
    command = Builder.hover(conn.sequence_number)
    {:noreply, buffer_command(conn, command, state: :airborn)}
  end

  def handle_cast({:move, movement, percent}, conn) when movement in @movements do
    command = apply(Builder, movement, [conn.sequence_number, percent])
    {:noreply, buffer_command(conn, command, state: :airborn)}
  end

  def handle_cast(:emergency_on, conn) do
    conn = buffer_command(conn, Builder.consider_emergency(conn.sequence_number), state: :emergency)
    conn = buffer_command(conn, Builder.emergency_on(conn.sequence_number), state: :emergency)
    {:noreply, conn}
  end

  def handle_cast(:emergency_off, conn) do
    conn = buffer_command(conn, Builder.emergency_off(conn.sequence_number), state: :resting)
    {:noreply, conn}
  end

  def handle_info(:flush, conn = Connection[bufferred_commands: []]) do
    command = Builder.hover(conn.sequence_number)
    {:noreply, buffer_command(conn, command, state: :airborn)}
  end
  def handle_info(:flush, conn) do
    conn.bufferred_commands
    |> Enum.reverse
    |> Builder.join_commands
    |> send_packet conn

    {:noreply, conn.bufferred_commands([])}
  end

  def send_packet(payload, conn) do
    :ok = :gen_udp.send conn.socket,
                        String.to_char_list!(conn.ip),
                        conn.port,
                        String.to_char_list!(payload)
  end

  defp buffer_command(conn, command, attributes // []) do
    defaults = [
      sequence_number: conn.sequence_number + 1,
      bufferred_commands: [command | conn.bufferred_commands]
    ]
    conn.update(Keyword.merge(defaults, attributes))
  end
end

