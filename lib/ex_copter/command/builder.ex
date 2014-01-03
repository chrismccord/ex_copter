defmodule ExCopter.Command.Builder do

  @ref_flags [
    takeoff:            0b00010001010101000000001000000000,
    land:               0b00010001010101000000000000000000,
    emergency:          0b00010001010101000000000100000000,
    consider_emergency: 0b00010001010101000000000000000000,
  ]

  @pcmd_flags [
    hover: 0b00000000000000000000000000000000,
    move:  0b00000000000000000000000000000001,
  ]

  def join_commands(commands), do: Enum.join(commands, "")

  def set_horizontal_plane(sequence_number) do
    "AT*FTRIM=#{sequence_number},\r"
  end

  def takeoff(sequence_num),        do: ref(:takeoff, sequence_num)
  def land(sequence_num),           do: ref(:land, sequence_num)
  def emergency_on(sequence_num),   do: ref(:emergency, sequence_num)
  def emergency_off(sequence_num),  do: ref(:emergency, sequence_num)
  def consider_emergency(sequence_num), do: ref(:consider_emergency, sequence_num)

  defp ref(ref_flag, sequence_number) do
    "AT*REF=#{sequence_number},#{@ref_flags[ref_flag]}\r"
  end

  def hover(sequence_number), do: pcmd(sequence_number, :hover, 0, 0, 0, 0)

  def roll_left(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, -float, 0, 0, 0)
  end

  def roll_right(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, float, 0, 0, 0)
  end

  def spin_left(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, 0, 0, -float)
  end

  def spin_right(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, 0, 0, float)
  end

  def pitch_forward(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, -float, 0, 0)
  end

  def pitch_backward(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, float, 0, 0)
  end

  def rise(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, 0, float, 0)
  end

  def lower(sequence_number, percent) do
    float = percent / 100.0
    pcmd(sequence_number, :move, 0, 0, -float, 0)
  end

  defp pcmd(sequence_number, flag, roll, pitch, gaz, yaw) do
    flag      = @pcmd_flags[flag]
    int_roll  = float_to_32int(roll)
    int_pitch = float_to_32int(pitch)
    int_gaz   = float_to_32int(gaz)
    int_yaw   = float_to_32int(yaw)

    "AT*PCMD=#{sequence_number},#{flag},#{int_roll},#{int_pitch},#{int_gaz},#{int_yaw}\r"
  end

  defp float_to_32int(float_value) do
    <<int_value :: [size(32), signed] >> = <<float_value ::[float, size(32)]>>

    int_value
  end
end

