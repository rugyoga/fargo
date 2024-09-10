defmodule Fargo.Scraper do

  @fargo_base "https://lms.fargorate.com/PublicReport"
  @sfpa_base "https://www.sfpapool.org/stats"
  @teams "GeneratePlayerStandingsByTeamReport"
  @players "GeneratePlayerListReport"
  @divisions "divisions"
  @weeks "week"
  @current_week "259/"
  @division "15"
  @key "bc9e8848-d262-43ca-a0af-b1d40027eb72?_=1724877356990"

  def players_url, do: [@fargo_base, @players, @key] |> Enum.join("/")
  def teams_url, do: [@fargo_base, @teams, @key] |> Enum.join("/")
  def divisions_url, do: [@sfpa_base, @divisions, @division] |> Enum.join("/")
  def current_week_url, do: [@sfpa_base, @weeks, @current_week] |> Enum.join("/")



  def parse_players(document) do
    [{_, _, players}] = Floki.find(document, "tbody")
    players
    |> Enum.map(fn {"tr", [], [{_, _, [name]}, {_, _, [rating]}]} -> {name, String.to_integer(rating)} end)
    |> Map.new()
  end

  def parse_teams(document) do
    [{_, _, teams}] = Floki.find(document, "tbody")
    teams
    |> Enum.map(
      fn {"tr", [{"class", "subtitle-row"}| _], [{"td", _, [name]}]} -> {:team, name}
      {"tr", [], players} -> Enum.map(players, fn {_, _, [name]} -> name end) |> List.first()
      end
    )
    |> Enum.reduce(
      [],
      fn {:team, name}, teams -> [{name, []}| teams]
          member, [{name, members}| teams] -> [{name, [flip(member) | members]} | teams]
      end)
  end

  def flip(name), do: name |> String.split(", ", trim: true) |> Enum.reverse |> Enum.join(" ")

  def parse_bar({"div", _, [{_, _, [name]}]}), do: String.trim(name)

  def parse_venue({"div", _, [{_, _, [venue]}]}), do: String.trim(venue)
  def parse_venue({"div", _, [venue]}), do: String.trim(venue)

  def parse_divisions(document) do
    Floki.find(document, "table")
    |> Enum.map(
      fn table ->
        table
        |> Floki.find("tbody tr td a")
        |> Enum.map(&(elem(&1, 2) |> hd))
      end
    )
  end

  def parse_match(document) do
    IO.inspect(document)
    [home, away, venue] = document |> Floki.find("td div")
    %{away: parse_bar(home), home: parse_bar(away), venue: parse_venue(venue)}
  end

  def parse_matches(document) do
    document
    |> Floki.find("table tbody tr")
    |> Enum.map(&parse_match/1)
  end

  def get_divisions do
    divisions_url()
    |> Fargo.Cache.get()
    |> parse_divisions()
    |> Enum.with_index(1)
    |> Enum.map(fn {a, b} -> {b, a} end)
    |> Map.new
  end

  def get_players, do: players_url() |> Fargo.Cache.get() |> parse_players()

  def get_week do
    current_week_url()
    |> Fargo.Cache.get()
    |> parse_matches()
  end

  def get_teams do
    map = get_players()
    teams_url()
    |> Fargo.Cache.get()
    |> parse_teams()
    |> Enum.map(fn {name, players} -> {name, Enum.map(players, &{&1, Map.fetch!(map, &1)}) |> Enum.sort_by(&elem(&1,1), :desc)} end)
    |> Map.new()
  end

  def range(players) do
    ratings = players |> Enum.unzip() |> elem(1)
    {average(Enum.take(ratings, 4)), average(Enum.take(ratings, -4))}
  end

  def average(ns), do: Enum.sum(ns) / (1.0 * length(ns))

  def get_division_strength do
    team_map = get_teams() |> Enum.map(fn {name, players} -> {name, range(players)} end) |> Map.new() |> IO.inspect(label: "team_map")
    get_divisions()
    |> Enum.map(fn {div, teams} -> {div, teams |> Enum.map(fn name -> {cleanse(name), team_map[cleanse(name)]} end) |> Enum.sort_by(fn {_, {max_strength, _}} -> max_strength end) } end)
  end

  def cleanse("The Black Willows"), do: "Black Willows"
  def cleanse("Bus Stop Pick Me Up"), do: "Bus Stop Pick Me up"
  def cleanse("Il Pirata Not Your FN Cisters"), do: "Il Pirata Not Your F'ing Cisters"
  def cleanse("Happy Diamond CueTTs"), do: "Happy Diamond CueTT's"
  def cleanse("Gino’s Diamonds"), do: "Gino's Diamonds"
  def cleanse("Coyle’s Nomads"), do: "Coyle's Nomads"
  def cleanse("Gino and Carlo Billiard Club"), do: "Gino & Carlo Billiard Club"
  def cleanse("Smoke & Fizz"), do: "Smoke and Fizz"
  def cleanse(x), do: x
end
