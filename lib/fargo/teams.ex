defmodule Fargo.Teams do
  def rawhides, do:
    [655, # mike maxwell
     582, # bob simon
     581, # joshua maldonado
     548, # tom seymour
     363, # jerry ball
     475, # rick mariani
     521 # leon waki
    ] |> pick()

  def indecisives, do:
    [
      562, # thayer mcdougle
      548, # evan burgess
      500, # skinner artega
      496, # jim neale
      468, # bill courtright
      455, # salvador miranda
      351 # brendon tang
    ] |> pick()

  def smokeandrumors, do:
    [
      571, # antonio cracchiolo
      539, # guy argo
      516, # rene denis
      453, # kevin dewar
      389, # anthony martinez
      402 # max sanchez
    ] |> pick()

  def happygotdiamond, do:
    [563, # modi shantharam
     455, # sara thomas
     431, # yuko takahashi
     429, # ben becker
     427, # joina liao
     364, # travis cline
     347, # lila butler
     306] # kathy chu
    |> pick()

  def irishbrigade, do:
    [573, # danny mullan
     546, # arthur mccaughey
     547, # daithi oleary
     547, # liam obrien
     523, # martin barron
     513] # chris loughran
    |> pick()

  def busstopflyers, do:
    [463, # teck scalia
     451, # justin anderson
     451, # jason burke
     440, # rich fullerton
     413, # tom purcell
     404] # ronnie selak
    |> pick()

  def poolcleaners, do:
    [596, # rohit patel
     570, # michael diep
     544, # wael al-sallami
     #535, # lee ribeiro
     517, # esau ortiz
     473, # jon williams (aka okie)
     448] # paul crouch
    |> pick()

  def nomads(), do:
    [600, # skip perry
     559, # willie gregory
     540, # jeff smith
     450, # brian paris
     410, # tim potter
     408, # finn mcdonald
     399, # jm reasonda
    ] |> pick()

  def wildhorses(), do:
    [540, # crystal kelem
     423, # walter rivera
     374, # perry logan
     335, # jocelyn angeles
     305, # joan pettijohn
     241] # jerry ervin
    |> pick()

  def churchillhaveeyes(), do:
    [
     473, # ari cowan
     471, # nick wells
     435, # travis yallup
     419, # roy luo
     407, # william huntington
     397, # tony tully
     352, # jessie manuel
    ] |> pick()

  def goldenstatewarriors(), do:
    [
      579, # rhys hughes
      552, # noah snyder
      522, # ben green
      476, # mark butler
      456, # marcelo aviles
      443 # fearghal mceleney
    ] |> pick()

  def blackbirdbankers(), do:
    [
     484, # matt raine
     445, # joshua badura
     429, # marco scabin
     384, # mark sorensen
     372, # kara cox
     372, # massimo giusti
     353 # kryhme jackson
  ] |> pick()

  def shovelready(), do:
    [
      458, # hugh fountain
      411, # sam khozindar
      362, # romy mancini
      343, # julia brown
      287, # bernie hirschbein
      277  # peter lee
    ] |> pick()

  def cleanslate(), do:
    [
      521, # nithin tharakan
      484, # joel talevi
      449, # rob ross
      432, # jamie dizon
      404, # mac cormier
      393 # patrick guilfoyle
    ] |> pick()

  def cinchpack(), do:
    [
      473, # bob schnatterly
      401, # james bavuso
      390, # john frakes
      359, # julia landholt
      356, # david norris
      279, # radley roberts
    ] |> pick()

  def gluefactory(), do:
    [
      547, # james horsfall
      506, # adam jackson
      454, # anthony hydron
      438, # rob moore
      426, # rick bradford
      416, # julien roeser
      387 # fran herman
    ] |> pick()


  def pick(team), do: team |> Enum.sort(:desc) |> Enum.take(4)
end
