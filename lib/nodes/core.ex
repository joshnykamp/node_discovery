defmodule Nodes.Core do
  require Logger
  @sync_dir "/temp/sync_dir"
  @interval 1_000

  def start() do
    loop()
  end

  def loop do
    sign_as_active_node()
    status = inspect check_active_nodes()
    Logger.info(Atom.to_string(Node.self) <> status)
    :timer.sleep(@interval)
  end

  def sign_as_active_node do
    File.mkdir_p @sync_dir
    {:ok, file} = File.open(path(), [:write])
    IO.binwrite file, time_now_as_string()
    File.close file
  end

  def check_active_nodes do
    active_nodes()
      |> Enum.map(&(String.to_atom &1))
      |> Enum.map(&({&1, Node.ping(&1) == :pong}))
  end

  def active_nodes do
    {:ok, active_members} = File.ls(@sync_dir)
    active_members
  end

  def path do
    @sync_dir <> Atom.to_string(Node.self)
  end

  def time_now_as_string do
    inspect :calendar.universal_time
  end
end
