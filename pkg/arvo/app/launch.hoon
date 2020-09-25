::  launch [landscape]:
::
::  registers Landscape (and third party) applications, tiles
::
/+  store=launch-store, default-agent, dbug
|%
+$  card  card:agent:gall
+$  versioned-state
  $%  [%0 *]
      [%1 *]
      [%2 *]
      [%3 *]
      [%4 state-zero]
      [%5 state-zero]
  ==
::
+$  state-zero
  $:  =tiles:store
      =tile-ordering:store
      first-time=?
  ==
--
::
=|  [%5 state-zero]
=*  state  -
%-  agent:dbug
^-  agent:gall
|_  =bowl:gall
+*  this  .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =/  new-state  *state-zero
  =.  new-state
    %_  new-state
        tiles
      %-  ~(gas by *tiles:store)
      %+  turn  `(list term)`[%weather %clock %dojo ~]
      |=  =term
      :-  term
      ^-  tile:store
      ?+  term      [[%custom ~] %.y]
          %dojo     [[%basic 'Dojo' '/~landscape/img/Dojo.png' '/~dojo'] %.y]
      ==
        tile-ordering  [%weather %clock %dojo ~]
    ==
  [~ this(state [%5 new-state])]
::
++  on-save  !>(state)
++  on-load
  |=  old=vase
  ^-  (quip card _this)
  =/  old-state  !<(versioned-state old)
  |-
  ?:  ?&(=(1 2) ?=(?(%4 %5) -.old-state))
    :-  [%pass / %arvo %e %disconnect [~ /]]~
    =.  tiles.old-state
      (~(del by tiles.old-state) %chat)
    =.  tiles.old-state
      (~(del by tiles.old-state) %publish)
    =.  tiles.old-state
      (~(del by tiles.old-state) %links)
    =.  tile-ordering.old-state
      (skip tile-ordering.old-state |=(=term ?=(?(%links %chat %publish) term)))
    this(state [%5 +.old-state])
  =/  new-state  *state-zero
  =.  new-state
    %_  new-state
        tiles
      %-  ~(gas by *tiles:store)
      %+  turn  `(list term)`[%weather %clock %dojo ~]
      |=  =term
      :-  term
      ^-  tile:store
      ?+  term      [[%custom ~] %.y]
          %dojo     [[%basic 'Dojo' '/~landscape/img/Dojo.png' '/~dojo'] %.y]
      ==
        tile-ordering  [%weather %clock %dojo ~]
    ==
  :_  this(state [%5 new-state])
  %+  welp
    :~  [%pass / %arvo %e %disconnect [~ /]]
        :*  %pass  /srv  %agent  [our.bowl %file-server]
            %poke  %file-server-action
            !>([%serve-dir / /app/landscape %.n %.y])
        ==
    ==
  %+  turn  ~(tap by wex.bowl)
  |=  [[=wire =ship =term] *]
  ^-  card
  [%pass wire %agent [ship term] %leave ~]
::
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ?>  (team:title our.bowl src.bowl)
  =^  cards  state
    ?+  mark  (on-poke:def mark vase)
        %launch-action  (poke-action !<(action:store vase))
    ==
  [cards this]
  ::
  ++  poke-action
    |=  =action:store
    ^-  (quip card _state)
    ?-  -.action
        %add
      ?<  (~(has by tiles) name.action)
      :-  (give [/all /keys ~] action)
      %_  state
          tiles          (~(put by tiles) name.action tile.action)
          tile-ordering  (snoc tile-ordering name.action)
      ==
    ::
        %remove
      :-  (give [/all /keys ~] action)
      %_  state
          tiles          (~(del by tiles) name.action)
          tile-ordering
        %+  skip  tile-ordering
        |=(=term =(term name.action))
      ==
    ::
        %change-order
      ?>  =(~(key by tiles) (silt tile-ordering.action))
      :-  (give [/all]~ action)
      state(tile-ordering tile-ordering.action)
    ::
        %change-is-shown
      =/  =tile:store  (~(got by tiles) name.action)
      ?.  =(is-shown.tile is-shown.action)  [~ state]
      =.  is-shown.tile  is-shown.action
      :-  (give [/all]~ action)
      state(tiles (~(put by tiles) name.action tile))
    ::
        %change-first-time
      :-  (give [/all]~ action)
      state(first-time first-time.action)
    ==
  ::
  ++  give
    |=  [paths=(list path) =update:store]
    ^-  (list card)
    [%give %fact paths [%launch-update !>(update)]]~
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  |^
  ?>  (team:title our.bowl src.bowl)
  =/  cards=(list card)
    ?+  path       (on-watch:def path)
        [%all ~]   (give [%initial tiles tile-ordering first-time])
        [%keys ~]  (give [%keys ~(key by tiles)])
    ==
  [cards this]
  ::
  ++  give
    |=  =update:store
    ^-  (list card)
    [%give %fact ~ [%launch-update !>(update)]]~
  --
::
++  on-peek
  |=  =path
  ^-  (unit (unit cage))
  ?.  (team:title our.bowl src.bowl)  ~
  ?+  path  [~ ~]
      [%x %tiles ~]       ``noun+!>([tiles tile-ordering])
      [%x %first-time ~]  ``noun+!>(first-time)
      [%x %keys ~]        ``noun+!>(~(key by tiles))
  ==
::
++  on-arvo
  |=  [wir=wire sin=sign-arvo]
  ^-  (quip card:agent:gall _this)
  ?:  ?=(%bound +<.sin)  [~ this]
  (on-arvo:def wir sin)
::
++  on-agent  on-agent:def
++  on-leave  on-leave:def
++  on-fail   on-fail:def
--
