/*
mt.gox live ticker for mIRC
by ageis @ #bitcoin-otc on freenode
modified: 11/02/2011
donations: 1AgeisUFv9NJ3AGGq7VPJWymGfFpCHDhCw

this script supplies small dialog(s)/window(s)
to load the script, type /load -rs mtgoxticker.mrc
!! you must allow initialization commands 
to set variables required by this script !!
to show the ticker, type /mtgoxticker
to configure settings, type /mtgoxsettings
or right-click for the menu

options:
- vertical or horizontal tickers	[default: horizontal]
- adjustable refresh rate		[default: 30 seconds]
- always on top				[default: on]
- show on desktop			[default: off]
- refresh while offline			[default: off]
*/

on *:LOAD:{
  unset mtgox*
  set %mtgoxurl https://mtgox.com/code/ticker.php
  set %mtgoxrefresh 30
  set %mtgoxaot 1
  set %mtgoxoffline 0
  set %mtgoxdesktop 0
  set %mtgoxvert 0
}

menu * {
  mt.gox
  ..ticker:mtgoxticker
  ..config:mtgoxsettings
}

dialog mtgoxconfig {
  title "settings" 
  size -1 -1 54 78
  option dbu
  check "always on top",1, 2 2 45 10, 
  check "show on desktop",2, 2 12 50 10, 
  check "refresh offline",3, 2 22 45 10,  
  combo 9,2 33 50 9, drop
  text "refresh rate:",4, 2 45 50 8, center
  edit "",5, 2 52 30 11, limit 5
  text "secs",6, 34 54 10 10
  button "okay",99, 2 66 50 10, ok flat
}

dialog mtgoxticker_vt {
  title "mt.gox" 
  size -1 -1 48 60
  option dbu
  text "AVG:" ,1, 2   0 14 8
  edit ""     ,2, 18  0 30 10,read
  text "LOW:" ,3, 2  10 14 8
  edit ""     ,4, 18 10 30 10,read
  text "HIGH:",5, 2  20 14 8
  edit ""     ,6, 18 20 30 10,read
  text "BID:" ,7, 2  30 14 8
  edit ""     ,8, 18 30 30 10,read
  text "ASK:" ,9, 2  40 14 8
  edit ""     ,10,18 40 30 10,read
  text "LAST:",11,2  50 14 8
  edit ""     ,12,18 50 30 10,read
  ;button "refresh", 99, 0 60 48 10, flat
}

dialog mtgoxticker_hz {
  title "mt.gox live ticker" 
  size -1 -1 276 10
  option dbu
  text "AVG:" ,1, 2   1 12 8
  edit ""     ,2, 16  0 30 10,read
  text "LOW:" ,3, 48  1 14 8
  edit ""     ,4, 64  0 30 10,read  
  text "HIGH:",5, 96  1 14 8
  edit ""     ,6, 112 0 30 10,read  
  text "BID:" ,7, 144  1 12 8
  edit ""     ,8, 156  0 30 10,read  
  text "ASK:" ,9, 188  1 12 8
  edit ""     ,10,200  0 30 10,read  
  text "LAST:",11,232  1 14 8
  edit ""     ,12,246  0 30 10,read  
  ;button "refresh", 99,278  0 32 10, flat
}

on *:dialog:mtgoxticker_vt:init:0:{ 
  mtgoxupdate mtgoxticker_vt
  if (%mtgoxoffline == 1) {
    .timergoxvt -o 0 %mtgoxrefresh mtgoxupdate mtgoxticker_vt
  }
  else { .timergoxvt 0 %mtgoxrefresh mtgoxupdate mtgoxticker_vt }
}
;on *:dialog:mtgoxticker_vt:sclick:99:{ mtgoxupdate mtgoxticker_vt }
on *:dialog:mtgoxticker_vt:close:0:{ .timergoxvt off }

on *:dialog:mtgoxticker_hz:init:0:{ 
  mtgoxupdate mtgoxticker_hz
  if (%mtgoxoffline == 1) {
    timergoxhz -o 0 %mtgoxrefresh mtgoxupdate mtgoxticker_hz
  }
  else { timergoxhz 0 %mtgoxrefresh mtgoxupdate mtgoxticker_hz }
}

;on *:dialog:mtgoxticker_hz:sclick:99:{ mtgoxupdate mtgoxticker_hz }
on *:dialog:mtgoxticker_hz:close:0:{ .timergoxhz off }

on *:dialog:mtgoxconfig:init:0:{
  did -arf mtgoxconfig 5 %mtgoxrefresh
  did -ai mtgoxconfig 9 vertical
  did -ai mtgoxconfig 9 horizontal

  if (%mtgoxvert == 1) { did -c mtgoxconfig 9 1 }
  else { did -c mtgoxconfig 9 2 }
  if (%mtgoxaot == 1) { did -c mtgoxconfig 1 }
  if (%mtgoxoffline == 1) { did -c mtgoxconfig 3 }
  if (%mtgoxdesktop == 1) { did -c mtgoxconfig 2 }
}

on *:dialog:mtgoxconfig:sclick:1:{
  if ($did(mtgoxconfig,1).state == 1) { set %mtgoxaot 1 }
  else { set %mtgoxaot 0 }
}

on *:dialog:mtgoxconfig:sclick:2:{
  if ($did(mtgoxconfig,2).state == 1) { set %mtgoxdesktop 1 }
  else { set %mtgoxdesktop 0 }
}

on *:dialog:mtgoxconfig:sclick:3:{
  if ($did(mtgoxconfig,3).state == 1) { set %mtgoxoffline 1 }
  else { set %mtgoxoffline 0 }
}

on *:dialog:mtgoxconfig:sclick:9:{
  if ($did(mtgoxconfig,9) == vertical) { set %mtgoxvert 1 }
  else { set %mtgoxvert 0 }
}
on *:dialog:mtgoxconfig:edit:5:{
  set %mtgoxrefresh $did(mtgoxconfig,5)
}

alias mtgoxticker {
  var %params -mv
  if (%mtgoxdesktop == 1) { %params = %params $+ d }
  if (%mtgoxaot == 1) { %params = %params $+ o }

  if (%mtgoxvert == 1) {
    dialog %params mtgoxticker_vt mtgoxticker_vt
  } 
  else { dialog %params mtgoxticker_hz mtgoxticker_hz }
}

alias mtgoxupdate {
  .jsonclearcache %mtgoxurl
  var %mtgoxavg $json(%mtgoxurl,ticker,avg)
  var %mtgoxhigh $json(%mtgoxurl,ticker,high)
  var %mtgoxlow $json(%mtgoxurl,ticker,low)
  var %mtgoxbid $json(%mtgoxurl,ticker,buy)
  var %mtgoxask $json(%mtgoxurl,ticker,sell)
  var %mtgoxlast $json(%mtgoxurl,ticker,last)
  did -ar $1 2 %mtgoxavg
  did -ar $1 4 %mtgoxlow
  did -ar $1 6 %mtgoxhigh
  did -ar $1 8 %mtgoxbid
  did -ar $1 10 %mtgoxask
  did -ar $1 12 %mtgoxlast 
}

alias mtgoxsettings {
  dialog -mov mtgoxconfig mtgoxconfig
}

;JSON implementation by Timi at http://timscripts.com/

alias json {
  if ($isid) {
    var %c = jsonidentifier,%x = 2,%str,%p,%v,%addr
    if ($isfile($1)) { %addr = $qt($replace($1,\,\\,;,\u003b,",\u0022)) }
    else { %addr = $qt($replace($1,;,\u003b,",\u0022)) }
    json.comcheck
    if (!$timer(jsonclearcache)) { .timerjsonclearcache -o 0 300 jsonclearcache }
    while (%x <= $0) {
      %p = $($+($,%x),2)
      if (%p == $null) { noop }
      elseif (%p isnum || $qt($noqt(%p)) == %p) { %str = $+(%str,[,%p,]) }
      else { %str = $+(%str,[",%p,"]) }
      inc %x
    }
    if ($prop == count) { %str = %str $+ .length }
    if ($isfile($1)) {
      if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),filejson,$chr(40),%addr,$chr(41),$chr(41),%str))) { return $com(%c).result }
    }
    elseif (http://* iswm $1 || https://* iswm $1) {
      if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),urlcache[,%addr,],$chr(41),%str))) { return $com(%c).result }
      elseif ($com(%c,eval,1,bstr,$+(urlcache[,%addr,]) = $+(httpjson,$chr(40),$qt($1),$chr(41)))) {
        if ($com(%c,eval,1,bstr,$+(str2json,$chr(40),urlcache[,%addr,],$chr(41),%str))) { return $com(%c).result }
      }
    }
    elseif ($com(%c,eval,1,bstr,$+(x=,%addr,;,x,%str,;))) { return $com(%c).result }
  }
}

alias jsonclearcache {
  if ($com(jsonidentifier)) {
    if (!$1) { noop $com(jsonidentifier,executestatement,1,bstr,urlcache = {}) }
    else { echo -qg $com(jsonidentifier,executestatement,1,bstr,urlcache[" $+ $1 $+ "] = "") }
  }
}

alias -l json.comcheck {
  var %c = jsonidentifier
  if (!$com(%c)) {
    .comopen %c MSScriptControl.ScriptControl
    noop $com(%c,language,4,bstr,jscript) $com(%c,addcode,1,bstr,function httpjson(url) $({,0) y=new ActiveXObject("Microsoft.XMLHTTP");y.open("GET",url,false);y.send();return y.responseText; $(},0))
    noop $com(%c,addcode,1,bstr,function filejson (file) $({,0) x = new ActiveXObject("Scripting.FileSystemObject"); txt1 = x.OpenTextFile(file,1); txt2 = txt1.ReadAll(); txt1.Close(); return txt2; $(},0))
    noop $com(%c,addcode,1,bstr,function str2json (json) $({,0) return !(/[^,:{}\[\]0-9.\-+Eaeflnr-u \n\r\t]/.test(json.replace(/"(\\.|[^"\\])*"/g, ''))) && eval('(' + json + ')'); $(},0))
    noop $com(%c,addcode,1,bstr,urlcache = {})
  }
}