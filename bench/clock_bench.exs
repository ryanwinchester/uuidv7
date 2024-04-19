defmodule ClockServer do
  use GenServer

  @clock_size 2 ** 18

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def next do
    GenServer.call(__MODULE__, :next)
  end

  def init(_args) do
    state = %{timestamp: System.system_time(:millisecond), counter: clock_init()}
    {:ok, state}
  end

  def handle_call(:next, _from, state) do
    current_ts = System.system_time(:millisecond)
    # Time-leap protection.
    current_ts = if current_ts < state.timestamp, do: state.timestamp, else: current_ts

    # Rollover protection.
    {current_ts, counter} =
      if state.counter == @clock_size do
        {current_ts + 1, clock_init()}
      else
        {current_ts, state.counter + 1}
      end

    state = %{state | counter: counter, timestamp: current_ts}
    {:reply, {current_ts, <<0::1, counter::big-unsigned-17>>}, state}
  end

  defp clock_init do
    <<clock::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
    clock
  end
end

alias UUIDv7.Clock

{:ok, _pid} = Clock.start_link([])
{:ok, _pid} = ClockServer.start_link([])

Benchee.run(%{
  "ClockServer" => fn -> ClockServer.next() end,
  "Clock" => fn ->
    <<seed::big-unsigned-17, _::7>> = :crypto.strong_rand_bytes(3)
    Clock.next(<<seed::big-unsigned-17>>)
  end
})
