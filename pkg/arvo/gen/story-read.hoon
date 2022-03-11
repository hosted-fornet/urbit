::  story: log commits in order
::
::::
  ::
/-  *story
/+  lib=story
:-  %say
|=  $:  [now=@da eny=@uvJ bec=beak]
        [[~] =desk ~]
    ==
|^
=/  our                   p.bec
=?  desk  =(*^desk desk)  q.bec  :: use current desk if user didn't provide
=/  cas=case              r.bec  :: use case from beak
?:  !(~(has in .^((set ^desk) %cd /(scot %p our)/$/(scot %da now))) desk)
  tang+[leaf+"Error: desk {<desk>} does not exist." ~]
=/  pax                   /(scot %p our)/[desk]/(scot cas)/story
?:  !.^(? %cu pax)        tang+['Error: No story file found. Please use |story-init to create one.' ~]
=/  tale                  .^(story %cx pax)
=/  current-tako          .^(tako:clay %cs /(scot %p our)/[desk]/(scot cas)/tako/~)
=/  current-yaki          .^(yaki:clay %cs /(scot %p our)/[desk]/(scot cas)/yaki/(scot %uv current-tako))
:-  %tang
(story-read [our desk cas] current-yaki tale)
::::
::  Remarks:
::
::  There are two recursions in the logging process:
::  1. the outer loop, `commit-loop` which threads downwards into each commit by ancestor
::  2. the inner loop, `ancestor-loop`, which threads left-to-right on reverse-ancestors
::
::  +story-read outputs a tang with the least-recent commits at the head of the list,
::  even though we want most-recent commits to end up printing first.
::  But because dojo prints tangs in reverse, we don't flop the results 
::::
++  story-read
  |=  [[our=ship syd=^desk cas=case] current-commit=yaki:clay tale=story]
  ^-  tang
  %-  head  :: result from state
  =|  state=[result=tang mergebase=(unit tako:clay)]
  |-
  ^-  _state
  =*  commit-loop  $
  =/  reverse-ancestors  (flop p.current-commit)
  |-
  =*  ancestor-loop  $
  ?-    reverse-ancestors
      ~
    ::  stop here and return the current message
    =/  msg=(list cord)  (msg-from-commit current-commit tale)
    [(weld msg result.state) mergebase=~]
  ::
      [tako:clay ~]
    =/  parent=tako:clay  i.reverse-ancestors
    =/  parent-commit     .^(yaki:clay %cs /(scot %p our)/[syd]/(scot cas)/yaki/(scot %uv parent))
    =/  msg               (msg-from-commit current-commit tale) 
    ::  If there is a mergebase and we are visting it right now:
    ::    stop here and clear the mergebase. 
    ::    skip adding the mergebase's msg itself because it will be added through the other branch
    ::  Otherwise, record the current message if exists
    ?:  ?&(?=(^ mergebase.state) =(u.mergebase.state r.current-commit))
      [result=result.state mergebase=~]
    commit-loop(current-commit parent-commit, result.state (weld msg result.state))
  ::
      [tako:clay tako:clay ~]
    ::
    ::  mainline: ultimate base chain
    ::  nowline: relative mainline
    ::  sideline: side-chain, featurebranch
    ::
    ::  From the context of e, commit c is on its relative mainline, or nowline, while commit d is on its sideline
    ::  %base  a--b-------------X  :: mainline
    ::  %new      \--c------e--/   :: nowline
    ::  %new2        \--d--/       :: sideline 
    ::
    ::  
    =/  sideline=tako:clay               i.reverse-ancestors
    =/  mainline=tako:clay               i.t.reverse-ancestors
    =/  mergebases                       .^((list tako:clay) %cs /(scot %p our)/[syd]/(scot cas)/base-tako/(scot %uv mainline)/(scot %uv sideline))  :: XX base-tako ignores beak
    =/  next-mergebase=(unit tako:clay)  ?~(mergebases ~ (some i.mergebases))  :: take the first valid mergebase (by convention) if exists, else none
    :: ~&  "Debug: Mergebase is null? {<=(~ next-mergebase)>}"
    =/  sideline-commit=yaki:clay        .^(yaki:clay %cs /(scot %p our)/[syd]/(scot cas)/yaki/(scot %uv sideline))
    =/  mainline-commit=yaki:clay        .^(yaki:clay %cs /(scot %p our)/[syd]/(scot cas)/yaki/(scot %uv mainline))
    =/  msg=(list cord)                  (msg-from-commit current-commit tale)
    ::
    ::  1 - process current commit
    ::  2 - recur and queue processing on all commits on the sideline
    ::  3 - recur and queue processing on all commits on the mainline
    ::
    ::  Because mainline messages are cons'd to result last, they are 
    ::  (by definition) towards the less recent side of the resulting flopped list
    ::
    =.  state  [result=(weld msg result.state) mergebase=next-mergebase]  :: 1
    =.  state  commit-loop(current-commit sideline-commit)                :: 2
    =.  state  commit-loop(current-commit mainline-commit)                :: 3
    state
  ::
      [tako:clay tako:clay tako:clay *]
    ~&  "in 3+ ancestor commit"
    =/  sideline=tako:clay               i.reverse-ancestors
    =/  nowline=tako:clay                i.t.reverse-ancestors
    =/  mergebases                       .^((list tako:clay) %cs /(scot %p our)/[syd]/(scot cas)/base-tako/(scot %uv nowline)/(scot %uv sideline))
    =/  next-mergebase=(unit tako:clay)  ?~(mergebases ~ (some i.mergebases))  :: take the first valid mergebase (by convention) if exists, else none
    =/  sideline-commit=yaki:clay        .^(yaki:clay %cs /(scot %p our)/[syd]/(scot cas)/yaki/(scot %uv sideline))
    =.  mergebase.state  next-mergebase
    =.  state            commit-loop(current-commit sideline-commit)           :: traverse downwards
    =.  state            ancestor-loop(reverse-ancestors t.reverse-ancestors)  :: traverse rightwards
    state
  ==
::
++  msg-from-commit
  |=  [commit=yaki:clay tale=story]
  ^-  (list cord)
  =/  proses  (~(get by tale) r.commit)
  ?~  proses  ~
  %-  flop    :: fix formatting reversal in dojo
  %-  to-wain:format
  %-  crip
  ;:  welp
    (tako-to-text:lib r.commit)
    (proses-to-text:lib u.proses)
  ==
--