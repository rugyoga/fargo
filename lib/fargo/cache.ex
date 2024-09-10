defmodule Fargo.Cache do
  use GenServer
  @active true

  @dir_name "fargo_cache"
  @server_name {:global, __MODULE__}

  def name, do: @server_name

  def start(_start, _arg) do
    start_link(nil)
  end

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: name())
  end

  @impl true
  def init(_arg) do
    {:ok, %{cache: %{}}, {:continue, temp_dir()}}
  end

  def temp_dir do
    temp = System.tmp_dir!()
    cache_dir = Path.join(temp, @dir_name)
    if !File.exists?(cache_dir) do
      File.mkdir!(cache_dir)
    end
    cache_dir
  end

  @impl true
  def handle_continue(temp_dir, _state) do
    temp_dir
    |> File.ls!()
    |> Enum.map(&Base.decode64!/1)
    |> Enum.map(fn filename -> {filename, load(temp_dir, filename)} end)
    |> Map.new()
    |> then(&{:noreply, %{cache: &1, temp_dir: temp_dir}})
  end

  def load(temp_dir, filename) do
    temp_dir
    |> Path.join(Base.encode64(filename))
    |> File.read!()
    |> :erlang.binary_to_term()
  end

  def save(temp_dir, filename, term) do
    temp_dir
    |> Path.join(Base.encode64(filename))
    |> File.write!(:erlang.term_to_binary(term))
  end

  @impl true
  def handle_call({:get, url}, _from, %{temp_dir: temp_dir, cache: cache} = state) do
    if Map.has_key?(cache, url) do
      {:reply, Map.fetch!(cache, url), state}
    else
      document = raw_get(url)
      save(temp_dir, url, document)
      {:reply, document, %{state | cache: Map.put(cache, url, document)}}
    end
  end

  defp raw_get(url) do
    response = HTTPoison.get!(url)
    {:ok, document} = Floki.parse_document(response.body)
    document
  end


  def get(url) do
    if @active do
      GenServer.call(@server_name, {:get, url}, :infinity)
    else
      raw_get(url)
    end
  end
end
