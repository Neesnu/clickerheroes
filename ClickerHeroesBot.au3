#include <ImageSearch.au3>
#include <NomadMemory.au3>
#include <Misc.au3>
#include <Array.au3> ; Required for _ArrayDisplay.
#include <GUIConstantsEx.au3>
#Include <GuiEdit.au3>
#Include <Date.au3>

; Author:	gorf18 (original by corruptryder)
; Date:		05-22-15
; Updated:	6-02-15
; Language:	AutoIt v3 (https://www.autoitscript.com/site/autoit/)
; This program serves as a bot for the Clicker Heroes (www.clickerheroes.com/) game.
; It uses a converted Image Search library imported from Auto Hot Key that was written
; by Aurelian Maga and Chris Mallett. This library is licensed under the GNU GENERAL PUBLIC LICENSE.

;========================================================================================================
;EDITING THIS SCRIPT

;If you do make changes to the source code you MUST run or compile it in x86 mode since the image search
;library was never updated for x64 and will not work at all.

; The main image search function looks like this.
;$result = _ImageSearchArea("image location", 1, $left, $top, $right, $bottom, location of image x ($x1), location of image y ($y1) , tolerance (0-255))
;  if $result = 1 Then
;	  MouseClick("left",$x1,$y1,1,5)
;  EndIf

; The tolerance means how close to the original image it must be - 0 means exactly the same, 255 means nothing the same.

; If you change or add any image searches you must make sure that the source image is available.

;========================================================================================================


; Main HotKeys for Starting and Stoping
HotKeySet("{F8}","runBot")
HotKeySet("{F9}","pause")
HotKeySet("{F10}","end")


; Makes sure that only one copy of this program can be running at once.
If _Singleton("ClickerHeroesBot", -1) = 0 Then
   Exit
EndIf

$ID=_MemoryOpen(WinGetProcess("Clicker Heroes"))
$goldAddress=0x0D8489E8
$scrollAddress=0x0B4BD63C

Global $timeMain = 0
Global $i = 0

; Game location properties
Global $left=0
Global $top=0
Global $right=0
Global $bottom=0
Global $width=0
Global $height=0
Global $gold = 0
Global $lastProgressToggle = _Date_Time_GetTickCount ( )
Global $hiringReduction = .5
Global $argaivLevel = 56
$wtit = 0
$border = 0
$scrollPos = 0
$scrollAmount = 80
$heroHeight = 148.75
$upgradeHeight = 470
$heroBoxHeight = 469

$x1=0
$y1=0
$x2=0
$y2=0

$HeroX = 0
$HeroY = 0
$lastHero = 0
$status1 = 0
$status2 = 0
$status3 = 0
$status4 = 0
Global $ascendBaseReached = False
$handle = WinGetHandle("Clicker Heroes", "")
Global $mostGold = 0

$Form1 = GUICreate("Logs", 1000, 700)
Global $editctrl = GUICtrlCreateEdit("", 10, 10, 450, 680)
Global $editctrl2 = GUICtrlCreateEdit("", 500, 10, 450, 680)
GUICtrlSetLimit($editctrl,10000000)
GUICtrlSetLimit($editctrl2,10000000)

Const $SM_CYCAPTION = 4
Const $SM_CXFIXEDFRAME = 7
$nextHero = 1
$wtit = 31
$border = 8
$downX = 0
$downY = 0
$upX = 0
$upY = 0
$scrollTop = 0
$scrollBottom = 0
$scrollDelta = 0
$thousand= 1000 ; 3
$million = $thousand * $thousand ; 6
$billion = $thousand * $million ;9
$trillion = $billion * $thousand ;12
$q = $trillion * $thousand ; 15
$Q = $q * $thousand ;18
$s = $Q * $thousand ;21
$S = $s * $thousand ;24
$U = $S * $trillion;36
$e51 = $U * $q ; 51
$e70 = $e51 * $Q * 10  ;70 = 51 + 18 + 1
$e85= $e70 * $q ; 85
$e100 = $e85 * $q
$e115 = $e100 * $q
$e130= $e115 * $q
$e145 = $e130 * $q
$e160= $e145 * $q


GUISetState(@SW_SHOW)

   ;Image,		CurrentLevel, 	BaseCost, LevelsToAdd, BaseDamage, 		Gilds, 		PersonalUpgrade, DPSupgradeHolder
Global $arrHeroes[35][8]= _
[ _
   ["cid.png",			0,		5,			0,			0,					0,			210			,0], _
   ["tree.png",			0,		50,			0,			5,					0,			20			,0], _
   ["ivan.png",			0,		250,		0,			22,					0,			20			,0], _
   ["brittany.png",		0,		1e3,		0,			74,					0,			20			,0], _
   ["fish.png",			0,		4e3,		0,			245,				0,			8			,0], _
   ["betty.png",		0,		2e4,		0,			976,				0,			1			,0], _
   ["samurai.png",		0,		1e5,		0,			3725,				104,		20			,0], _
   ["leon.png",			0,		4e5,		0,			10859,				0,			8			,0], _
   ["forest.png",		0,		2.5e6,		0,			47143,				0,			20			,0], _
   ["alexa.png", 		0,		1.5e7,		0,			1.86e5,				0,			5.0625		,0], _
   ["natalia.png",		0,		1e8,		0,			7.82e5,				0,			20			,0], _
   ["mercedes.png",		0,		8e8,		0,			3.721e6,			0,			20			,0], _
   ["bobby.png", 		0,		6.5e9,		0,			1.701e7,			0,			20			,0], _
   ["broyle.png",		0,		5e10,		0,			6.9064e7,			0,			10			,0], _
   ["george.png",		0,		4.5e11,		0,			4.6e8,				0,			20			,0], _
   ["king.png",			0,		4e12,		0,			3.017e9,			0,			1			,0], _
   ["jerator.png",		0,		3.6e13,		0,			2.0009e10,			0,			20			,0], _
   ["abaddon.png",		0,		3.2e14,		0,			1.31e11,			0,			11.390625	,0], _
   ["zhu.png",			0,		2.7e15,		0,			8.14e11,			0,			20			,0], _
   ["amen.png",			0,		2.4e16,		0,			5.335e12,			0,			2			,0], _
   ["beast.png",		0,		3e17,		0,			4.9143e13,			0,			8			,0], _
   ["athena.png",		0,		9e18,		0,			1.086e15,			0,			16			,0], _
   ["aphrodite.png",	0,		3.5e20,		0,			3.1124e16,			0,			16			,0], _
   ["shinatobe.png",	0,		1.4e22,		0,			9.17e17,			0,			8			,0], _
   ["grant.png",		0,		4.199e24,	0,			2.02e20,			0,			4			,0], _
   ["frostleaf.png",	0,		2.1e27,		0,			7.4698e22,			0,			4			,0], _
   ["dread.png",		0,		1e40,		0,			1.31e32,			0,			20			,0], _
   ["Atlas.png",		0,		1e55,		0,			9.65e44,			0,			20			,0], _
   ["terra.png",		0,		1e70,		0,			7.113e57,			0,			20			,0], _
   ["phthalo.png",		0,		1e85,		0,			5.24e70,			0,			20			,0], _
   ["temp.png",			0,		1e100,		0,			3.861e83,			0,			20			,0], _
   ["temp.png",			0,		1e115,		0,			2.845e96,			0,			20			,0], _
   ["temp.png",			0,		1e130,		0,			2.096e109,			0,			20			,0], _
   ["temp.png",			0,		1e145,		0,			1.544e122,			0,			20			,0], _
   ["temp.png",			0,		1e160,		0,			1.137e135,			0,			20			,0] _
   ]
Global $curHero = 0
Global $result = 0
Global $hTimer = TimerInit();
Global $lastRunTurnStatus = 0



;showAll()
setHero()
Func scrollTo($x, $lookFor)
   getScrollPos()

   ControlClick($handle,"", "", "Left",1,461, 387)

if $upX = 0 And $upY = 0 Then
   $result = _ImageSearchArea("images/up.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   if $result = 1 Then
	  $upX = $x1
	  $upY = $y1
   Else
	  return 0
   EndIf

EndIf
if $downX = 0 And $downY = 0 Then
   $result = _ImageSearchArea("images/down.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   if $result = 1 Then
	  $downX = $x1
	  $downY = $y1
   Else
	  return 0
   EndIf
EndIf
if $x = -1 Then
   clickMouseScreen($downX, $downY - 35, "Left")
   sleep(200)
   clickMouseScreen($downX, $downY, "Left")
   clickMouseScreen($downX, $downY, "Left")
   $lastHero = $curHero
   Return
EndIf
if $x = 0 Then
   clickMouseScreen($upX, $upY + 35, "Left")
   sleep(200)
   clickMouseScreen($upX, $upY, "Left")
   clickMouseScreen($upX, $upY, "Left")
   $lastHero = 3
   Return
EndIf
$diff = Abs($x - $lastHero)
_GUICtrlEdit_AppendText($editctrl2,"Looping To: " &$x & " From: "& $lastHero & @CRLF)
if $diff > $curHero/2 Then

   if $x < $curHero/2 Then
	  clickMouseScreen($upX, $upY + 35, "Left")
	  $lastHero = 0
   Else
	  clickMouseScreen($downX, $downY - 35, "Left")
	  $lastHero = $curHero
   EndIf



EndIf
$loop = 0
$loopLoop = 0
while (true)

   if $lastHero > $x Then
	  clickMouseScreen($upX, $upY, "Left")
   Else
	  clickMouseScreen($downX, $downY, "Left")
   EndIf
   sleep(50)
   $result = _ImageSearchArea($lookFor, 1, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)
   if($result = 1) Then
	  ;_GUICtrlEdit_AppendText($editctrl2,"LoopDone:" & @CRLF)
	  Return
   EndIf
   if($loop > 50) Then
	  clickMouseScreen($downX, $downY - 35, "Left")
	  $lastHero = $curHero
	  $loopLoop = $loopLoop +1
	  $loop = 0
   EndIf
   if($loopLoop > 3) Then
	 Return
   EndIf
   $loop = $loop + 1
WEnd
Return






$varbottom = ($curhero + 1) * $heroHeight + $upgradeHeight - $heroBoxHeight
$diff = $goal/$varbottom
$val = $diff * (($downY-35) - ($upY + 35)) + $upY + 35

_GUICtrlEdit_AppendText($editctrl2,"HeroHieght: " & ($curhero + 1) * $heroHeight & " additional " & $upgradeHeight - $heroBoxHeight & " x: " & $x & @CRLF)
_GUICtrlEdit_AppendText($editctrl2,"Ytop: " & $upY + 35 & " YBottom " &$downY-35 & @CRLF)
_GUICtrlEdit_AppendText($editctrl2,"Click: " & $upX & " " &$val & @CRLF)
MouseClick($upX,$val)
return
$origPos = $scrollPos
sleep(500)
getScrollPos()
$lastpos = $scrollPos

EndFunc

;Sets Initial Hero Levels
Func setHero()
   $curhero = 1

   checkScreen()

   ;Cid
   $arrHeroes[0][1]= 0
   ;Tree
   $arrHeroes[1][1]= 0
   ;Ivan
   $arrHeroes[2][1]= 0
   ;Brittany
   $arrHeroes[3][1]= 0
   ;Fisherman
   $arrHeroes[4][1]= 0
   ;Betty
   $arrHeroes[5][1]= 0
   ;Samurai
   $arrHeroes[6][1]= 0
   ;Leon
   $arrHeroes[7][1]= 0
   ;Forest
   $arrHeroes[8][1]= 0
   ;Alexa
   $arrHeroes[9][1]= 0
   ;Natalia
   $arrHeroes[10][1]= 0
   ;Mercedes
   $arrHeroes[11][1]= 0
   ;Bobby
   $arrHeroes[12][1]= 0
   ;Fire
   $arrHeroes[13][1]= 0
   ;George
   $arrHeroes[14][1]= 0
   ;King
   $arrHeroes[15][1]= 0
   ;Jerator
   $arrHeroes[16][1]= 0
   ;Abaddon
   $arrHeroes[17][1]= 0
   ;Ma Zhu
   $arrHeroes[18][1]= 0
   ;Amenhotep
   $arrHeroes[19][1]= 0
   ;Beastlord
   $arrHeroes[20][1]= 0
   ;Athena
   $arrHeroes[21][1]= 0
   ;Aphrodite
   $arrHeroes[22][1]= 0
   ;Shinatobe
   $arrHeroes[23][1]= 0
   ;Grant
   $arrHeroes[24][1]= 0
   ;FrostLeaf
   $arrHeroes[25][1]= 0
   ;Good Measure
   $arrHeroes[26][1]= 0


EndFunc

Func reset()
   _GUICtrlEdit_AppendText($editctrl,"reset"  & @CRLF)
   $nexthero = 1

   Local $iHours = 0, $iMins = 0, $iSecs = 0
   Local $iEnd = TimerDiff($hTimer)
   _TicksToTime($iEnd, $iHours, $iMins, $iSecs)
   _GUICtrlEdit_AppendText($editctrl2,"Time to Ascend: " & StringFormat("%02d:%02d:%02d", $iHours, $iMins, $iSecs)  & @CRLF)
   ; The main varibales are all reset back to the defaults
		 $timeMain = 24
		 $ascendBaseReached = False
		 checkScreen()
		 $hTimer = TimerInit();

		 $mostGold = 0

   ;Set to CurHero
   $curHero=0
   ;Cid
   $arrHeroes[0][1]= 0
   ;Tree
   $arrHeroes[1][1]= 0
   ;Ivan
   $arrHeroes[2][1]= 0
   ;Brittany
   $arrHeroes[3][1]= 0
   ;Fisherman
   $arrHeroes[4][1]= 0
   ;Betty
   $arrHeroes[5][1]= 0
   ;Samurai
   $arrHeroes[6][1]= 0
   ;Leon
   $arrHeroes[7][1]= 0
   ;Forest
   $arrHeroes[8][1]= 0
   ;Alexa
   $arrHeroes[9][1]= 0
   ;Natalia
   $arrHeroes[10][1]= 0
   ;Mercedes
   $arrHeroes[11][1]= 0
   ;Bobby
   $arrHeroes[12][1]= 0
   ;Fire
   $arrHeroes[13][1]= 0
   ;George
   $arrHeroes[14][1]= 0
   ;King
   $arrHeroes[15][1]= 0
   ;Jerator
   $arrHeroes[16][1]= 0
   ;Abaddon
   $arrHeroes[17][1]= 0
   ;Ma Zhu
   $arrHeroes[18][1]= 0
   ;Amenhotep
   $arrHeroes[19][1]= 0
   ;Beastlord
   $arrHeroes[20][1]= 0
   ;Athena
   $arrHeroes[21][1]= 0
   ;Aphrodite
   $arrHeroes[22][1]= 0
   ;Shinatobe
   $arrHeroes[23][1]= 0
   ;Grant
   $arrHeroes[24][1]= 0
   ;FrostLeaf
   $arrHeroes[25][1]= 0
   ;Good Measure
   $arrHeroes[26][1]= 0

EndFunc
Func getScrollPos()
   $scrollPos=_MemoryRead($scrollAddress,$ID)
   #comments-start
   if ($scrollTop = 0 And $scrollBottom = 0) And ($upY <> 0 And $downY <> 0) Then
	  clickMouseScreen($upX,$upY + 35, "Left")
	  sleep(1000)
	  $result = _ImageSearchArea("images/TabTop.png", 1, $left, $top, $left + $width/2, $bottom, $x1, $y1, 10)
	  if $result = 1 Then
		 _GUICtrlEdit_AppendText($editctrl,"$y1: " & $y1 & " $x1: " & $x1 &@CRLF)
		 $scrollTop = $y1
		 sleep(1000)
	  EndIf

	  clickMouseScreen($upX,$downY - 35, "Left")
	  sleep(1000)
	  $result = _ImageSearchArea("images/Tab.png", 1, $left, $top, $left + $width/2, $bottom, $x1, $y1, 10)
	  if $result = 1 Then
		 _GUICtrlEdit_AppendText($editctrl,"$y1: " & $y1 & " $x1: " & $x1 &@CRLF)
		 $scrollBottom = $y1
		 sleep(1000)
	  EndIf
   EndIf

   $varbottom = ($curhero + 1) * $heroHeight + $upgradeHeight - $heroBoxHeight
   $result = _ImageSearchArea("images/Tab.png", 1, $left, $top, $left + $width/2, $bottom, $x1, $y1, 10)
   if $result = 1 Then
		$scrollPos = (($y1 - $scrollTop)/($scrollBottom - $scrollTop)) * $varbottom
   EndIf
   #comments-end

EndFunc

Func getGold()
   $gold=_MemoryRead($goldAddress,$ID ,"double")
EndFunc

Func runBot()
   ; Gets the bounding rectangle of clicker heroes

   checkScreen()

   Local $iHours = 0, $iMins = 0, $iSecs = 0
   Local $iEnd = TimerDiff($hTimer)
   _TicksToTime($iEnd, $iHours, $iMins, $iSecs)
   _GUICtrlEdit_AppendText($editctrl2,"Runbot: " & StringFormat("%02d:%02d:%02d", $iHours, $iMins, $iSecs) & @CRLF)
   _GUICtrlEdit_AppendText($editctrl2,"PLEASE PRESS F10 TO STOP ME" & @CRLF)
   checkFarmState()
   checkCurHero()
   ;If we arnt starting with an override then start
   ;If $curHero = 0 Then
	;  checkHeroes()
   ;EndIf
   ; Makes the script run indefinately
   While ($i = 0)
   ;ControlClick($handle, "", "", "WU", 1)
   ; This is where the main running of the bot happens. The bot runs on ticks and whenever the tick
   ; amount gets to a certain point, the methods will get called. Currently the methods are spaced
   ; apart to let the more important methods get more calls. To change how often a certain method
   ; will be executed, you can change the amount below in the brackets. A higher number means less
   ; times it will get executed, while a lower number means it will get executed more often.


	  ; Gets the bounding rectangle of clicker heroes every 15 ticks
	  If Mod($timeMain,15) = 0 Then
		 checkScreen() ;WORKING
	  EndIf

	  ; Checks the farm button state every 60 ticks
	  If Mod($timeMain,4) = 0 Then
		 ;_GUICtrlEdit_AppendText($editctrl2,"TickCheck: " & $lastProgressToggle + 41000& " CurTick: " & _Date_Time_GetTickCount() & @CRLF)
		 if($lastProgressToggle + 40000 * 1.5 < _Date_Time_GetTickCount() Or $lastProgressToggle > _Date_Time_GetTickCount()) Then

			$thisRunStatus = checkFarmState() ;WORKING
			if $thisRunStatus = 0 Then
			   $lastRunTurnStatus = 0
			   _GUICtrlEdit_AppendText($editctrl2,"Farm progress Reset" & @CRLF)
			EndIf

			$lastRunTurnStatus = $lastRunTurnStatus + $thisRunStatus
			_GUICtrlEdit_AppendText($editctrl2,"Farm progress Counter: " & $lastRunTurnStatus & @CRLF)
			if $lastRunTurnStatus >= 3 Then

			   _GUICtrlEdit_AppendText($editctrl2,"Ascending" & @CRLF)
			   $lastRunTurnStatus = 0
			   Ascend()

			EndIf
		 EndIf
	  EndIf


	  ; Checks for the upgrade box every 30 ticks
	  If Mod($timeMain,120) = 0 Then
		 clickUpgadeBox() ;WORKING
	  EndIf

	  ; Find the fish!
	  If Mod($timeMain,6) = 0 Then
		 findFish()
	  EndIf

	  ; Calls the level up method every tick
	  If Mod($timeMain,1) = 0 Then
		 altLevelUp3()
	  EndIf

	  ; Calls the level up method every tick
	  ;If Mod($timeMain,6) = 0 Then
		; checkGild()
	  ;EndIf

	  $timeMain = $timeMain + 1

	  ; A delay can be introduced into the tick so that everything will run slower
	  ;Sleep(500)
   WEnd
EndFunc
Func checkGild()
   $result = _ImageSearchArea("images/gild.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   if $result = 1 Then
	  clickMouseScreen($x1,$y1, "Left")
	  $result = _WaitForImageSearchArea("images/gildchest.png", 2, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	  if $result = 1 Then
		 clickMouseScreen($x1,$y1, "Left")
		 $result = _WaitForImageSearchArea("images/Exit.png", 2, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		 if $result = 1 Then
			clickMouseScreen($x1,$y1, "Left")
		 EndIf
	  EndIf
   EndIf



EndFunc

; Gets the bounding rectangle of clicker heroes
Func checkScreen()
   Local $aPos = WinGetPos("Clicker Heroes")

   $left = $aPos[0] + $border
   $top = $aPos[1] + $wtit
   $right = $left + $aPos[2] - $border * 2
   $bottom = $top + $aPos[3] - ($border + $wtit)
   $width = $right - $left
   $height = $bottom - $top

   ;_ImageSearchArea('check5.bmp', 1, left, top, right, bottom, $x, $y, 0)
EndFunc
Func clickMouseScreen($xpos, $ypos, $click, $count = 1)
   ControlClick($handle,"", "",$click,$count,$xpos - $left,$ypos - $top)
EndFunc

; Checks that the farm state is still turned on
Func checkFarmState()
   $lastProgressToggle = _Date_Time_GetTickCount ( )
   $result = _ImageSearchArea("images/farmoff.png", 1, $left, $top, $right, $bottom, $x1, $y1, 40)
   if $result = 1 Then

	  _GUICtrlEdit_AppendText($editctrl2,"Turn on Progression, TickCount: " & $lastProgressToggle & @CRLF)
	  clickMouseScreen($x1,$y1,"Left")

	  Sleep(1000)
	  return 1
   EndIf
   return 0
EndFunc

Func findFish()
   ;Fish Find
   $result = _ImageSearchArea("images/fish.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
	  If $result = 1 Then
		 clickMouseScreen($x1,$y1, "Left")
		 _GUICtrlEdit_AppendText($editctrl2,"Fish Found!" & @CRLF)
	  EndIf
EndFunc


Func RecurseLevel($pos)
   $value = 0
   findHeroPure($pos)
   $value = AltLevelHero()
   if $value > 0 Then
	  _GUICtrlEdit_AppendText($editctrl,"L-Up " & $arrHeroes[$lastHero][0] & " + " & $value & " = " & $arrHeroes[$lastHero][1] & @CRLF)
   EndIf
   if $pos - 1 >= 1 Then
	  sleep(500)
	  RecurseLevel($pos - 1)
   EndIf




EndFunc
Func LeveUPXAmount()
   _GUICtrlEdit_AppendText($editctrl,"Got To LevelUp - " & $arrHeroes[$lastHero][0] & " To Level:" & $arrHeroes[$lastHero][3] + $arrHeroes[$lastHero][1]& " From Level: "  & $arrHeroes[$lastHero][1] &  @CRLF)
   $value = $arrHeroes[$lastHero][3]
   $result = _WaitForImageSearchArea("images/level.png",0.5,  1, $left, $HeroY, $HeroX, $HeroY + ($bottom/8), $x2, $y2, 120)
   if $result = 0 Then
	  $result = _WaitForImageSearchArea("images/hire2.png",0.5,  1, $left, $HeroY, $HeroX, $HeroY + ($bottom/8), $x2, $y2, 120)
	  if $result = 0 Then
		 return 0;
	  EndIf
   EndIf
   #comments-start
   $var = Floor($value / 100)
   $value = $value - $var * 100

   if $var >= 1 Then
   ControlSend ("Clicker Heroes","","","{CTRLDOWN}")

   for $loop = 1 To $var

   sleep(100)
   _GUICtrlEdit_AppendText($editctrl,"Add 100 Levels" & @CRLF)
   clickMouseScreen($x2, $y2, "Left")
   $value = $value - 100
   $arrHeroes[$lastHero][1] = $arrHeroes[$lastHero][1] + 100
   sleep(100)
Next

   ControlSend ("Clicker Heroes","","","{CTRLUP}")

   EndIf

   $var = Floor($value / 25)
   $value = $value - $var * 25
   if $var >= 1 Then

   ControlSend ("Clicker Heroes","","","{Z DOWN}")

   for $loop = 1 To $var

   sleep(100)
   _GUICtrlEdit_AppendText($editctrl,"Add 25 Levels" & @CRLF)
   clickMouseScreen($x2, $y2, "Left")
   $value = $value - 25
   $arrHeroes[$lastHero][1] = $arrHeroes[$lastHero][1] + 25
   sleep(100)
   Next

   ControlSend ("Clicker Heroes","","","{Z UP}")

EndIf

   $var = Floor($value / 10)
   $value = $value - $var * 10
   if $var >= 1 Then
   ControlSend ("Clicker Heroes","","","{SHIFTDOWN}")
   for $loop = 1 To $var

   sleep(100)
   _GUICtrlEdit_AppendText($editctrl,"Add 10 Levels" & @CRLF)
   clickMouseScreen($x2, $y2, "Left")
   $value = $value - 10
   $arrHeroes[$lastHero][1] = $arrHeroes[$lastHero][1] + 10
   sleep(100)
   Next

   ControlSend ("Clicker Heroes","","","{SHIFTUP}")
   sleep(1000)
   EndIf

#comments-end
;_GUICtrlEdit_AppendText($editctrl,"Add " & $value & " Levels" & @CRLF)
   if $value >= 1 Then
   for $loop = 1 To $value

   clickMouseScreen($x2, $y2, "Left")
   $value = $value - 1
   $arrHeroes[$lastHero][1] = $arrHeroes[$lastHero][1] + 1
   sleep(20)
Next

EndIf
   clickMouseScreen($HeroX, $HeroY, "Left")
   $arrHeroes[$lastHero][3] = 0
   return $value
EndFunc
Func TraceOutline($l, $t, $r, $b, $string = "")
   _GUICtrlEdit_AppendText($editctrl,"Tracing: " & $string & @CRLF)
   MouseMove($l, $t)
   MouseMove($r, $t)
   MouseMove($r, $b)
   MouseMove($l, $b)
   MouseMove($l, $t)
EndFunc

Func AbstractLevel($level, $string, $value, $checkOrange = 1)
   $upgrades = 0
   $result = 1
   while ($result = 1 And $upgrades < 5)
	  $x2 = 0
	  $y2 = 0
	  $x3 = 0
	  $y3 = 0
	  $result = _WaitForImageSearchArea($level ,0.5,  1, $left, $HeroY, $HeroX, $HeroY + ($bottom/8), $x2, $y2, 10)
	  If $result = 1 Then
		 If $checkOrange = 1 Then
			$result = _WaitForImageSearchArea("images/orange.png",.2, 1, $left, $y2, $x2, $y2 + ($bottom/8), $x3, $y3, 10)
			If $result = 0 Then
			   $result = 1
			Else
			   $result = 0
			EndIf
		 EndIf
		 If $result = 1 Then

			$upgrades = $upgrades + 1
			clickMouseScreen($x2,$y2, "Left")
			$arrHeroes[$lastHero][1]= $arrHeroes[$lastHero][1] + $value
			sleep(50)
			clickMouseScreen($HeroX,$HeroY, "Left")
		 EndIf
	  EndIf
   WEnd
   return $upgrades * $value
EndFunc
Func altLevelUp2()

   $return = findHeroPure($nexthero)
   if $return = 0 Then
	  Return
   EndIf

   checkStatus();
   if $status1 = 1 Then
	  clickMouseScreen($x2,$y2, "Left")
	  $arrHeroes[$lastHero][1]= 1
	  if $lastHero > $curhero Then
		 _GUICtrlEdit_AppendText($editctrl,"Set Hero to:  " & $lastHero & @CRLF)
		 $curhero = $lastHero
	  EndIf
   EndIf
   _GUICtrlEdit_AppendText($editctrl,"level Hero: " & $arrHeroes[$lastHero][0] & @CRLF)
   $value = AltLevelHero()
   if $value > 0 Then
	  _GUICtrlEdit_AppendText($editctrl,"L-Up " & $arrHeroes[$lastHero][0] & " + " & $value & " = " & $arrHeroes[$lastHero][1] & @CRLF)
   EndIf
   $nexthero = $nexthero - 1
   if $nexthero <= 1 Then
	  $nexthero = $curhero + 1
   EndIf


EndFunc
Func checkCurHero()
   while($gold > $arrHeroes[$curhero][2])
	   $curhero = $curhero+1
	   if $curhero > 34 Then
		  $curhero = 34
		  Return
	   EndIf
	   _GUICtrlEdit_AppendText($editctrl2,"Current Hero = " &$curhero& @CRLF)
	WEnd

 EndFunc
 Func ascendLevelUp()
$nexthero = $curhero

While($nexthero >= 0)
   getGold()
   $levels = CalcHeroLevelsForGold($nexthero, $gold)
   $levels = Floor($levels *.9)
   if($levels >= 1) Then
	  $arrHeroes[$nexthero][3] = $levels
	  findHeroPure($nexthero)
	  LeveUPXAmount()
   EndIf
   $nexthero = $nexthero - 1;
WEnd



EndFunc



Func altLevelUp3()

if $nexthero = 0 Then
   getGold()
   if($gold < $mostGold) Then
	  Return
   EndIf
   $mostGold = $gold
   checkCurHero()
   EstimateHeroLevels()
   $nexthero = $curhero

EndIf
if $arrHeroes[$nexthero][3] + $arrHeroes[$nexthero][1] = $arrHeroes[$nexthero][1] Then

Else

   $result = findHeroPure($nexthero)
   ;_GUICtrlEdit_AppendText($editctrl,"Found Hero : " & $result & @CRLF)
   if $result = 1 then
	  _GUICtrlEdit_AppendText($editctrl,"Send To LevelUp" &  @CRLF)
	  LeveUPXAmount()
   EndIf
EndIf
   $nexthero = $nexthero - 1


EndFunc
Func CalculateDPS($h, $newLevel)
   ;HeroDps					   Level				 Gilds									PersonalBonus
   $damage = $arrHeroes[$h][4] * $newLevel * (1 + (.51  + $argaivLevel *.02) * $arrHeroes[$h][5]) * $arrHeroes[$h][6]
   $multiplier = 1;
   $workingLevel = $newLevel
   if($workingLevel > 1000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
   if($workingLevel > 2000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
   if($workingLevel > 3000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
	  $workingLevel = $workingLevel - 175
   if($workingLevel>=25)Then

	  $multiplier = $multiplier * (4 ^ (Floor(($newLevel - 175)/25)))

   EndIf

   return $damage * $multiplier
EndFunc

Func CalculateNewDPS($h, $oldLevel, $newLevel)
    $new = CalculateDps($h, $newLevel)
	$old = CalculateDps($h, $oldLevel)
   $arrHeroes[$h][7] = $new - $old
   return $arrHeroes[$h][7]
EndFunc
Func EfficientBuy()
$checkhero = $curHero + 1
$hero = -1
$effectiveness  = 0
$addlevels = 0
While($checkhero >= 1)
   $arrHeroes[$checkhero][7] = 0
   $currentestimate = CalcHeroLevelsForGold($checkhero, $gold)
   $newDps = CalculateNewDPS($checkhero, $arrHeroes[$checkhero][1], $arrHeroes[$checkhero][1] + $currentestimate)
   $cost = CalcHeroGoldCost($checkhero, $arrHeroes[$checkhero][1] + $currentestimate)
   $eff = $newDps/$gold
   if($eff > $effectiveness) Then
	  $addlevels = $currentestimate
	  $effectiveness = $eff
	  $hero = $checkhero

   EndIf



$checkhero = $checkhero -1
WEnd
if($hero <> -1)Then
$arrHeroes[$hero][3] = $addlevels
EndIf
EndFunc





Func ExpertLog($Number, $Base)
    return Log($Number) / Log($Base)
 EndFunc

Func CalcHeroLevelsForGold($h, $goldcount)
   $var2 = ($goldcount/($arrHeroes[$h][2] * $hiringReduction))* (1-1.07)
   $var3 = 1.07^$arrHeroes[$h][1]
   $var = ExpertLog($var3 - $var2, 1.07)
   $tempvalue = Floor ($var)

    return $tempvalue - $arrHeroes[$h][1]
 EndFunc
 Func CalcHeroGoldCost($h, $newlevel)

   $var2 = 1.07^$arrHeroes[$h][1]
   $var3 = 1.07^($arrHeroes[$h][1] + $newlevel)
   $var = (1-1.07)




	$var1 =$arrHeroes[$h][2] * ($var2 - $var3)/$var;getGeometricSum($arrHeroes[$h][2], 1.07, $arrHeroes[$h][1]-1, $arrHeroes[$h][1] + $newlevel)
	;_GUICtrlEdit_AppendText($editctrl,"-----$h " & $h & " $newlevel " & $newlevel & " $var1 " & $var1 & "--------" & @CRLF)
	return $var1
 EndFunc
 Func getMaxLevel($gold,$factor, $base, $lev)
   $vartop = $lev - 1
   $varBottom = ExpertLog($gold * (1 - $base), $base)/$factor
   $end = $vartop/$varBottom
   	return $end
EndFunc

Func getGeometricSum($factor, $base, $firstexponent, $second)
   $front = $base^$firstexponent
   $back = $base^($second)
   $bot = (1-$base)
   $final = (($front - $back)/($bot))
   	return $factor * $final
 EndFunc
 Func verify150()
	$flag = 0
	$goldestimate = $gold
	for $var = 1 To $curHero + 1
	   if($arrHeroes[$var][1] < 150 And $goldestimate > 0) Then
		 $currentestimate = CalcHeroLevelsForGold($var, $goldestimate)
		 if($currentestimate + $arrHeroes[$var][1] > 150) Then
		 $tempvalue = Mod ( $currentestimate + $arrHeroes[$var][1], 150 )
		 $currentestimate = $currentestimate - $tempvalue
		 $goldUsed = CalcHeroGoldCost($var, $currentestimate)
		 $arrHeroes[$var][3] = $currentestimate
		 $goldestimate= $goldestimate - $goldUsed
		 _GUICtrlEdit_AppendText($editctrl2,"QuickExit" & @CRLF)
		 return 1
	  EndIf
	  EndIf


   Next
   return 0
EndFunc
Func EstimateHeroLevels()
if $gold < 50 Then
   clickMouseScreen($left + ($width / 1.2 ), $top + (($height) / 2), "Left")
   Return
EndIf
$herocount = 0
$herotarget = $curhero
$checkhero = $curhero
if(verify150() = 1) Then
   _GUICtrlEdit_AppendText($editctrl2,"QuickExit" & @CRLF)
   Return
EndIf
EfficientBuy()
return;
$goldEstimate = $gold
_GUICtrlEdit_AppendText($editctrl2,"Start $gold" & $goldEstimate & @CRLF)
While($checkhero >= 1)
   $arrHeroes[$checkhero][3] = 0
   $currentestimate = 0
   $currentlevel = $arrHeroes[$checkhero][1]

   $currentestimate = CalcHeroLevelsForGold($checkhero, $goldEstimate)
   $tempvalue = Mod ( $currentestimate + $currentlevel, 25 )
   ;_GUICtrlEdit_AppendText($editctrl,"-----$tempvalue " & $tempvalue & " From " & $currentestimate & " cost " & $currentestimate & "--------" & @CRLF)
  ; $weee = CalcHeroGoldCost($checkhero, $tempvalue)
   ;_GUICtrlEdit_AppendText($editctrl,"L-UpTo " & $arrHeroes[$checkhero][1] + $arrHeroes[$checkhero][3] & " From " & $arrHeroes[$checkhero][1] & " cost " & $weee & @CRLF)
   if $arrHeroes[$checkhero][1] + $currentestimate < 100 Then
   Else
	  $oldCurrent = $currentestimate
	  $currentestimate = $currentestimate - $tempvalue
   EndIf
   if $currentestimate >= 1 Then
	  $goldUsed = CalcHeroGoldCost($checkhero, $currentestimate)
	  if $goldUsed < $goldEstimate Then
		 $goldEstimate = $goldEstimate - $goldUsed
		 ;_GUICtrlEdit_AppendText($editctrl,"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"& @CRLF)
		 $arrHeroes[$checkhero][3] = $currentestimate
		 ;_GUICtrlEdit_AppendText($editctrl,"L-UpTo " & $arrHeroes[$checkhero][1] + $arrHeroes[$checkhero][3] & " From " & $arrHeroes[$checkhero][1] & @CRLF)
		 ;_GUICtrlEdit_AppendText($editctrl,"$goldUsed " & $goldUsed & " $goldEstimate " & $goldEstimate & @CRLF)
		 ;_GUICtrlEdit_AppendText($editctrl,"vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv"& @CRLF)
	  Else
		 _GUICtrlEdit_AppendText($editctrl,"WHAT THE FUCK?!" & @CRLF)
	  EndIf
   EndIf
   $checkhero = $checkhero - 1

WEnd

EndFunc

Func altLevelUp()
1.581e33
   findHeroPure($curhero + 1)
   checkStatus();
   if $status1 = 1  Or $status3  = 1 Then
	  clickMouseScreen($x2,$y2, "Left")
	  $arrHeroes[$lastHero][1]= 1
	  $curhero = $lastHero
   EndIf

   RecurseLevel($curhero)



EndFunc
Func findHeroPure($pos)
   ;Check if Previous Hero is Hired else Abort
   ;_GUICtrlEdit_AppendText($editctrl,"findHero Hero: " & $arrHeroes[$pos][0] & @CRLF)
   Local $heroFound = 0
   Local $loopDown = 0
   Local $loopOverall = 0
   Local $foundButton = 0
   Local $waitTime = .4

   if $pos = 5 Or $pos = 7 Or $pos = 15 Or $pos = 17 Or $pos = 18 Or $pos = 20 Then
	  $waitTime = 1;
   EndIf

   While ($loopOverall < 5)
	  $result = _WaitForImageSearchArea("images/heroes/" & $arrHeroes[$pos][0], $waitTime, 1, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)
	  If $result = 1 Then
		 ;_GUICtrlEdit_AppendText($editctrl,"Found Hero " & $arrHeroes[$pos][0] &@CRLF)
		 $HeroX = $x1
		 $HeroY = $y1
		 $lastHero = $pos
		 Return 1
	  Else
		 scrollTo($pos, "images/heroes/" & $arrHeroes[$pos][0])

		 Sleep( 300 )
		 $loopOverall = $loopOverall + 1
		 $result = _ImageSearchArea("images/salvageRelicsOkay.png", 1, $left, $top, $right, $bottom, $x1, $y1, 60)
			If $result = 1 Then
			   clickMouseScreen($x1,$y1, "Left")
			EndIf
	  EndIf
   Wend
   Return 0
EndFunc
Func checkStatus()

   $status1 = _ImageSearchArea("images/hire2.png", 1, $left, $HeroY, $HeroX, $y1 + ($height/9), $x2, $y2, 60)
   $status2 = _ImageSearchArea("images/hire.png", 1, $left, $HeroY, $HeroX, $y1 + ($height/9), $x2, $y2, 60)
   $status3 = _ImageSearchArea("images/level.png", 1, $left, $HeroY, $HeroX, $y1 + ($height/9), $x2, $y2, 60)
   $status4 = _ImageSearchArea("images/level2.png", 1, $left, $HeroY, $HeroX, $y1 + ($height/9), $x2, $y2, 60)

EndFunc



; Clicks the buy available upgrades box
Func clickUpgadeBox()
   scrollTo(-1, "images/buyAvailableUpgrades.png")
   Sleep(300)
   ;_GUICtrlEdit_AppendText($editctrl,"Scrolled " & $x1 & " " & $y1 &@CRLF)
   $result = _ImageSearchArea("images/buyAvailableUpgrades.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   If $result = 1 Then
	  ;_GUICtrlEdit_AppendText($editctrl,"Found Button " & $x1 & " " & $y1 &@CRLF)
		 clickMouseScreen($x1,$y1, "Left")
   EndIf
   $lastHero = $curHero
   Sleep(300)
EndFunc
Func searchHighestHero()
   _GUICtrlEdit_AppendText($editctrl,"SearchHeroes" &@CRLF)
   $lasthero = 35
   $result = 0
   While($result = 0 And $lasthero >= $curhero)

	  _GUICtrlEdit_AppendText($editctrl,"SearchHeroes " & $lasthero &@CRLF)
	  $lasthero = $lasthero - 1
	  $result = _ImageSearchArea("images/heroes/" & $arrHeroes[$lasthero][0], 1, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)


   WEnd
   _GUICtrlEdit_AppendText($editctrl,"Hero: " & $curhero & @CRLF)
   $curhero = $lasthero - 1
   EndFunc

; Finds and clicks the ascend button to restart
Func Ascend()
   _GUICtrlEdit_AppendText($editctrl,"Trying to Ascend" & @CRLF)

   $result =  _WaitForImageSearchArea("images/loot.png", 1, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   If $result = 1 Then
      _GUICtrlEdit_AppendText($editctrl,"loot" & @CRLF)
	  clickMouseScreen($x1,$y1, "Left")
	  $result =  _WaitForImageSearchArea("images/junk.png", 1.5, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	  If $result = 1 Then
		 _GUICtrlEdit_AppendText($editctrl,"Junk" & @CRLF)
		 clickMouseScreen($x1,$y1, "Left")
		 $result =  _WaitForImageSearchArea("images/junkYes.png", 1.5, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
		 If $result = 1 Then
			_GUICtrlEdit_AppendText($editctrl,"JunkYes" & @CRLF)
			clickMouseScreen($x1,$y1, "Left")
		 EndIf
	  EndIf
   EndIf
   $result =  _WaitForImageSearchArea("images/backToProgress.png", 0.5, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   $lastHero = 0
   If $result = 1 Then
      _GUICtrlEdit_AppendText($editctrl,"loot" & @CRLF)
	  clickMouseScreen($x1,$y1, "Left")
   EndIf

   ;Move Up and Wait
   ;ascendLevelUp()
   ;sleep(5000)
   ;Find Amen
   findHeroPure(19)

   _GUICtrlEdit_AppendText($editctrl,"Found Amen" & @CRLF)
   Sleep(500)
   $result =  _WaitForImageSearchArea("images/ascend2.png", 0.3, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   If $result = 1 Then
      _GUICtrlEdit_AppendText($editctrl,"Found Ascend" & @CRLF)
	  clickMouseScreen($x1,$y1, "Left")
	  Sleep(500)
	  $result = _WaitForImageSearchArea("images/ascendYes.png",0.3, 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	  If $result = 1 Then
		 clickMouseScreen($x1,$y1, "Left")
		 Sleep(3000)

		 reset()
		 ; Extra clicks happen at the beginning to makes sure that a hero can be found when the ticks start again
		 newGame()

		 runBot()
	  Else
		_GUICtrlEdit_AppendText($editctrl,"Didnt Find Ascend Yes Button" & @CRLF)
	  EndIf
   Else
		_GUICtrlEdit_AppendText($editctrl,"Didnt Find Ascend" & @CRLF)
   EndIf

EndFunc

;Gets New Game Going
Func newGame()
   checkFarmState() ;WORKING
$result = 0
$result2 = 0
   While($result2=0)
	  ; Gets the bounding rectangle of clicker heroes every 15 ticks
	  If Mod($timeMain,45) = 0 Then
		 checkScreen() ;WORKING
	  EndIf

	  ; Checks the farm button state every 60 ticks
	  If Mod($timeMain,30) = 0 Then
		 checkFarmState() ;WORKING
	  EndIf
	  ;TODO FIX THIS
	  	  ;TODO FIX THIS
	  $result = _WaitForImageSearchArea("images/heroes/tree.png", .4, 1, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)
	  _GUICtrlEdit_AppendText($editctrl,"Found Tree!" & @CRLF)
	  If $result = 1 Then
		 $result2 = _WaitForImageSearchArea("images/hire2.png" ,0.5,  1, $left, $y1, $x1, $y1 + ($bottom/8), $x2, $y2, 10)
		 _GUICtrlEdit_AppendText($editctrl,"Hire? " & $result2 & @CRLF)
	  EndIf
	  if $result = 0 Then

		 ; Extra clicks happen at the beginning to makes sure that a hero can be found when the ticks start again
		 For $clicks = 0 To 4 Step 1
			ControlClick($handle,"", "", "Left",1,$left + ($width / 1.2 ), $top + (($height) / 2))
		 Next
	  EndIf
	  ;Attempt to Hire Cid


   WEnd
   $curhero = 1
EndFunc

Func checkHero($pos)

   If ($arrHeroes[$pos][1]= 0) Then
	  $result = _ImageSearchArea("images/heroes/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 0 Then
		 $result = _ImageSearchArea("images/heroes/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  EndIf
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($height/9), $x2, $y2, 120)
		 If $result = 1 and $pos <> 25 Then
			$arrHeroes[$pos][1]= 1
			$curHero = $pos
		 EndIf
		 $result = _ImageSearchArea("images/level2.png", 1, $left, $y1, $x1, $y1 + ($height/9), $x2, $y2, 120)
		 If $result = 1 and $pos <> 25 Then
			$arrHeroes[$pos][1]= 1
			$curHero = $pos
		 EndIf
	  EndIf
   EndIf

EndFunc

; Loads Hero List
Func checkHeroes()
do


   If ($arrHeroes[0][1]= 0) Then
	  $result = _ImageSearchArea("images/heroes/cid.png", 1, $left, $top, $left + $width / 2,  $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 _GUICtrlEdit_AppendText($editctrl,"Found Cid Image" & @CRLF)
		 $result = _ImageSearchArea("images/Hire.png", 1, $left, $y1, $x1, $y1 + ($height/9), $x2, $y2, 120)
		 If $result = 1 Then
			_GUICtrlEdit_AppendText($editctrl,"Found Cid Hire Image" & @CRLF)
			newGame()
		 Else
			_GUICtrlEdit_AppendText($editctrl,"Didnt find Cid Hire Image" & @CRLF)
			$result = _ImageSearchArea("images/hire2.png", 1, $left, $y1, $x1, $y1 + ($height/9), $x2, $y2, 120)
			If $result = 1 Then
			   _GUICtrlEdit_AppendText($editctrl,"Found Cid Hire2 Image" & @CRLF)
			   newGame()
			Else
			   _GUICtrlEdit_AppendText($editctrl,"Didnt find Cid Hire2 Image" & @CRLF)
			   $arrHeroes[0][1]= 1
			EndIf
		 EndIf
	  Else
		 _GUICtrlEdit_AppendText($editctrl,"Cant find cid.png on the screen" & @CRLF)
	  EndIf
   EndIf
until 1
EndFunc

;=======================================================================================
;MSGBOX
Func showAll()
   MsgBox(0,"Keys and Values", "Start Script: " & @TAB & @TAB & @TAB & "F8" & @LF & "Pause Script: " & @TAB & @TAB & @TAB & "F9" & @LF & "Stop Script: " & @TAB & @TAB & @TAB & "F10" & @LF & @LF & "Access this Keys and Values box: " & @TAB & "~" & @LF & @LF & "NOTE: This box must be closed before starting the script." & @LF &"___________________________________________________________________" & @LF & @LF & "Next Farm State Check: " & @TAB & @TAB & 60 - Mod($timeMain,60) & @TAB & "ticks" & @LF & "Next Hero Soul Check: " & @TAB & @TAB & 60 - Mod($timeMain,60) & @TAB & "ticks" & @LF & "Next Special Item Check: " & @TAB & @TAB & 10 - Mod($timeMain,10) & @TAB & "ticks" & @LF & "Next Buy Available Upgrades Check: " & @TAB & 30 - Mod($timeMain,30) & @TAB & "ticks" & @LF & "Next Ascension Check: " & @TAB & @TAB & 10 - Mod($timeMain,10) & @TAB & "ticks" & @LF & "Ascension Base Amount (8) reached: " & @TAB & $ascendBaseReached & @LF & "Next Round Check: " & @TAB & @TAB & @TAB & 6 - Mod($timeMain,6) & @TAB & "ticks" & @LF & @TAB & "no lvlUps" & @LF & "___________________________________________________________________" & @LF & @LF &  "Force Farm State Check: " & @TAB & @TAB & "!" & @LF & "Force Bulk Level Up: " & @TAB & @TAB & @TAB & "@" & @LF & "Toggle Total Hero Amount Reached: " & @TAB & "#" & @LF & "Toggle Ascend Base Reached: " & @TAB & @TAB & "$" & @LF & "Force Hero Soul Check: " & @TAB & @TAB & "%" & @LF & "Force Ascension: " & @TAB & @TAB & @TAB & "^"& @LF & "___________________________________________________________________" & @LF & @LF & "If you have any feedback or bugs to report, you can contact me" & @LF & " on reddit @ gorf18"& @LF & @LF & "v1.0.6")
EndFunc
;=======================================================================================

; Auxiliary functions for pausing the script, exiting and keeping it running while there is no activity
Func pause()
   ControlSend ("Clicker Heroes","","","{CTRLUP}")
   While ($i = 0)
	  Sleep(30)
   WEnd
EndFunc

Func end()
   Send("{Z UP}")
   Send("{SHIFTUP}")
   Send("{CTRLUP}")
   _MemoryClose($ID)
   Exit
EndFunc

While $i = 0
   Sleep(100)
WEnd
