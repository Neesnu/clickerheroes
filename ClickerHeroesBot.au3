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
; screen Variables
Global $left=0
Global $top=0
Global $right=0
Global $bottom=0
Global $width=0
Global $height=0
;Top and side Borders
Global $wtit = 31
Global $border = 8
; Game state holders
Global $gold = 0
Global $lastProgressToggle = _Date_Time_GetTickCount ( )
Global $dogcogLevel = 25
Global $argaivLevel = 221
Global $timeToKillBoss = 50
;Tells if a fish is on screen
Global $foundFish = 0
;Save this for a restart?
Global $waitFish = 1
Global $ascend = 0
;Positions for the up down arrows for the hero pane
Global $downX = 0
Global $downY = 0
Global $upX = 0
Global $upY = 0
;Change this if you want to click every cycle, still working on exits for certain things
Global $idle = 1
Global $lastClick = TimerInit()
Global $lastAscend = TimerInit()
Global $AscentionMinutes = 55
Global $timedAscention = 1

; Need to check these
$x1=0
$y1=0
$x2=0
$y2=0

;the highest hero we can see
Global $curHero = 0
;Counter that tells up when to ascend.
Global $lastRunTurnStatus = 0
;Next Hero to check
Global $nextHero = 1
;location holders for the found hero X and Y Pos
Global $HeroX = 0
Global $HeroY = 0
;Last hero we found
Global $lastHero = 0

$handle = WinGetHandle("Clicker Heroes", "")
Global $mostGold = 0
Global $upgradeCounter = 0

$Form1 = GUICreate("Logs", 1000, 700,1280,720)
Global $editctrl = GUICtrlCreateEdit("", 10, 10, 450, 680)
Global $editctrl2 = GUICtrlCreateEdit("", 500, 10, 450, 680)
GUICtrlSetLimit($editctrl,10000000)
GUICtrlSetLimit($editctrl2,10000000)

Const $SM_CYCAPTION = 4
Const $SM_CXFIXEDFRAME = 7





GUISetState(@SW_SHOW)
;General game information and holders for hero variables
   ;Image,		CurrentLevel, 	BaseCost, LevelsToAdd, BaseDamage, 		Gilds, 		PersonalUpgrade, DPSupgradeHolder
Global $arrHeroes[35][8]= _
[ _
   ["cid.png",			0,		5,			0,			1,					0,			210			,0], _
   ["tree.png",			0,		50,			0,			5,					0,			20			,0], _
   ["ivan.png",			0,		250,		0,			22,					0,			20			,0], _
   ["brittany.png",		0,		1e3,		0,			74,					0,			20			,0], _
   ["fish.png",			0,		4e3,		0,			245,				0,			8			,0], _
   ["betty.png",		0,		2e4,		0,			976,				0,			1			,0], _
   ["samurai.png",		0,		1e5,		0,			3725,				141,		20			,0], _
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
   ["didensy.png",		0,		1e100,		0,			3.861e83,			0,			20			,0], _
   ["temp.png",			0,		1e115,		0,			2.845e96,			0,			20			,0], _
   ["temp.png",			0,		1e130,		0,			2.096e109,			0,			20			,0], _
   ["temp.png",			0,		1e145,		0,			1.544e122,			0,			20			,0], _
   ["temp.png",			0,		1e160,		0,			1.137e135,			0,			20			,0] _
   ]

Global $result = 0
Global $hTimer = TimerInit();




;showAll()
setHero()
Func scrollTo($x, $lookFor)
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
   $lastHero = $curHero
   Sleep(300)
   Return

EndIf
if $x = 0 Then
   clickMouseScreen($upX, $upY + 35, "Left")
   $lastHero = 3
   Sleep(300)
   Return
EndIf
$diff = Abs($x - $lastHero)
_GUICtrlEdit_AppendText($editctrl2,"Looping To: " &$x & " From: "& $lastHero & @CRLF)
if $diff > $curHero/2 Then

   if $x < $curHero/2 Then
	  clickMouseScreen($upX, $upY + 35, "Left")
	  $lastHero = 3
	  Sleep(300)
	  Return
   Else
	  clickMouseScreen($downX, $downY - 35, "Left")
	  $lastHero = $curHero
	  Sleep(300)
	  Return
   EndIf



EndIf
$loop = 0
$loopLoop = 0
while (true)
    $result = checkTwoImages("images/heroes/normal/" & $lookFor, "images/heroes/gild/" & $lookFor, 0, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)
   if($result = 1) Then
	  ;_GUICtrlEdit_AppendText($editctrl2,"LoopDone:" & @CRLF)
	  Return
   EndIf

   if $lastHero > $x Then
	  clickMouseScreen($upX, $upY, "Left")
   Else
	  clickMouseScreen($downX, $downY, "Left")
   EndIf
   sleep(50)

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
   $arrHeroes[2][1]= 34
   ;Brittany
   $arrHeroes[3][1]= 30
   ;Fisherman
   $arrHeroes[4][1]= 1
   ;Betty
   $arrHeroes[5][1]= 0
   ;Samurai
   $arrHeroes[6][1]= 83
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

   ; The main varibales are all reset back to the defaults
   $timeMain = 0
   checkScreen()
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

Func getGold()
   $gold=_MemoryRead($goldAddress,$ID ,"double")
EndFunc

Func runBot()
   ; Gets the bounding rectangle of clicker heroes

   checkScreen()

   _GUICtrlEdit_AppendText($editctrl2,"PLEASE PRESS F10 TO STOP ME" & @CRLF)
   checkFarmState()
   checkCurHero()
   ; Makes the script run indefinately
   While (true)
   ; This is where the main running of the bot happens. The bot runs on ticks and whenever the tick
   ; amount gets to a certain point, the methods will get called. Currently the methods are spaced
   ; apart to let the more important methods get more calls. To change how often a certain method
   ; will be executed, you can change the amount below in the brackets. A higher number means less
   ; times it will get executed, while a lower number means it will get executed more often.


	  ; Gets the bounding rectangle of clicker heroes every 15 ticks
	  If Mod($timeMain,15000) = 0 Then
		 checkScreen() ;
	  EndIf

	  If Mod($timeMain,400) = 0 Then
		 ;ascends if the critera are met
		 ascend()
	  EndIf
	  if($timedAscention = 4) Then
		 if( TimerDiff($lastAscend) > $AscentionMinutes*60*1000 ) Then
			$ascend = 1;
		 EndIf
	  EndIf

	  ;clicks the screen and DPSSSSES
	  If($idle <> 1) Then
		 $lastClick = TimerInit()
		 ControlClick($handle,"", "", "Left",1,$left + ($width / 1.2 ), $top + (($height) / 2))
		 Sleep(30)
	  EndIf

	  ; Checks the farm button state every 60 ticks
	  If Mod($timeMain,30) = 0 Then
		 if($lastProgressToggle + 50000 * 1.5 < _Date_Time_GetTickCount() Or $lastProgressToggle > _Date_Time_GetTickCount()) Then

			$thisRunStatus = checkFarmState() ;
			if $thisRunStatus = 0 Then
			   $lastRunTurnStatus = 0
			   _GUICtrlEdit_AppendText($editctrl2,"Farm progress Reset" & @CRLF)
			EndIf

			$lastRunTurnStatus = $lastRunTurnStatus + $thisRunStatus
			_GUICtrlEdit_AppendText($editctrl2,"Farm progress Counter: " & $lastRunTurnStatus & @CRLF)
			if $lastRunTurnStatus >= 3 Then

			   _GUICtrlEdit_AppendText($editctrl2,"Ascending" & @CRLF)
			   $lastRunTurnStatus = 0
			   $ascend = 1
			EndIf
		 EndIf
	  EndIf


	  ; Checks for the upgrade box every 30 ticks
	  If Mod($timeMain,200) = 0 Then
		 clickUpgadeBox() ;
	  EndIf

	  ; Find the fish!
	  If Mod($timeMain,30) = 0 Then
		 findFish()
	  EndIf

	  ; Calls the level up method every tick
	  If Mod($timeMain,1) = 0 Then
		 LevelUpAlgorthim()
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
;Shouldnt use this unless you have the images ready to go, will make it so you cant find the hero that gets gilded if they arent already gilded
Func checkGild()
   $result = _ImageSearchArea("images/gild.png", 1, $left + $width * 3/4, $top + $height * 3/4, $right, $bottom, $x1, $y1, 120)
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
EndFunc

;This converts the screen space coordinates into the game screen for ControlClick
Func clickMouseScreen($xpos, $ypos, $click, $count = 1)
   ControlClick($handle,"", "",$click,$count,$xpos - $left,$ypos - $top)
EndFunc

; Checks that the farm state is still turned on
Func checkFarmState()
   $lastProgressToggle = _Date_Time_GetTickCount ( )
   $result = _ImageSearchArea("images/farmoff.png", 1, $left + $width * 3/4 , $top + $height * 3/4, $right, $bottom - $height/2, $x1, $y1, 40)
   if $result = 1 Then

	  _GUICtrlEdit_AppendText($editctrl2,"Turn on Progression, TickCount: " & $lastProgressToggle & @CRLF)
	  clickMouseScreen($x1,$y1,"Left")

	  Sleep(1000)
	  return 1
   EndIf
   return 0
EndFunc

;Finds the fish
Func findFish()
   if($foundFish = 1)Then
	  Return
   EndIf
   $result = _ImageSearchArea("images/fish.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
	  If $result = 1 Then
		 if($waitFish = 1) Then
			$foundFish = 1
			_GUICtrlEdit_AppendText($editctrl2,"Fish Found!" & @CRLF)
		 Else
			clickMouseScreen($x1,$y1, "Left")
			_GUICtrlEdit_AppendText($editctrl2,"Clicked Fish!" & @CRLF)
		 EndIf
	  EndIf
   EndFunc
;Clicks the fish
Func clickFish()
   $result = _ImageSearchArea("images/fish.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
	  If $result = 1 Then
		 clickMouseScreen($x1,$y1, "Left")
		 _GUICtrlEdit_AppendText($editctrl2,"Clicked Fish!" & @CRLF)
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

   if $value >= 1 Then
   for $loop = 1 To $value
   if($idle <> 1) Then
	  $dif = TimerDiff($lastClick)
	  if($dif >= 8000) Then
		 return $value
	  EndIf
   EndIf
   clickMouseScreen($x2, $y2, "Left")
   $value = $value - 1
   $arrHeroes[$lastHero][1] = $arrHeroes[$lastHero][1] + 1
   $arrHeroes[$lastHero][3] = $arrHeroes[$lastHero][3] - 1
   sleep(20)
Next

EndIf
   ;clickMouseScreen($HeroX, $HeroY, "Left")

   return $value
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
Func TraceOutline($l, $t, $r, $b, $string = "")
   _GUICtrlEdit_AppendText($editctrl,"Tracing: " & $string & @CRLF)
   MouseMove($l, $t)
   MouseMove($r, $t)
   MouseMove($r, $b)
   MouseMove($l, $b)
   MouseMove($l, $t)
EndFunc

Func LevelUpAlgorthim()

 if $nexthero = -1 Then
   getGold()
   if($gold < $mostGold) Then
	  Return
   EndIf
   $mostGold = $gold * .8
   checkCurHero()
   EstimateHeroLevels()
   $nexthero = $curhero

EndIf
if $arrHeroes[$nexthero][3] > 0 Then
   $result = findHero($nexthero)
   if $result = 1 then
	  LeveUPXAmount()
   EndIf
EndIf

if($arrHeroes[$nexthero][3] == 0) Then
   $nexthero = $nexthero - 1
EndIf

EndFunc
Func CalculateDPS($h, $newLevel)
   ;HeroDps					   Level				 Gilds									PersonalBonus
   $damage = $arrHeroes[$h][4] * $newLevel * (1 + (.51  + $argaivLevel *.02) * $arrHeroes[$h][5]) * $arrHeroes[$h][6]
   $multiplier = 1;
   $Level = $newLevel
   if($Level > 1000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
   if($Level > 2000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
   if($Level > 3000) Then
	  $multiplier = $multiplier * 2.5
   EndIf
	  $Level = $Level - 175
   if($Level>=25)Then

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
   if($currentestimate < 0) Then
	  $currentestimate = 0
   EndIf
   $newDps = CalculateNewDPS($checkhero, $arrHeroes[$checkhero][1], $arrHeroes[$checkhero][1] + $currentestimate)
   $cost = CalcHeroGoldCost($checkhero, $currentestimate)
   $eff = 0
   if($cost <> 0) Then
	  $eff = $newDps/$cost
   EndIf
   if($eff > $effectiveness) Then
	  $addlevels = $currentestimate
	  $effectiveness = $eff
	  $hero = $checkhero

   EndIf
$checkhero = $checkhero -1
WEnd
if($hero <> -1)Then
$arrHeroes[$hero][3] = $addlevels
$nexthero = $hero
EndIf
EndFunc

Func ExpertLog($Number, $Base)
    return Log($Number) / Log($Base)
 EndFunc
Func CalcHeroLevelsForGold($h, $goldcount)
   $var2 = ($goldcount/($arrHeroes[$h][2] * (1  - $dogcogLevel * .02)))* (1.07-1)
   $var3 = 1.07^$arrHeroes[$h][1]
   $var = ExpertLog($var2 + $var3, 1.07)
   $tempvalue = Floor ($var)
    return $tempvalue - $arrHeroes[$h][1]
 EndFunc
 Func CalcHeroGoldCost($h, $newlevel)
	$lev =  $arrHeroes[$h][1] + $newlevel
	$var2 = getGeometricSingleSum($arrHeroes[$h][2] * (1  - $dogcogLevel * .02), 1.07, $lev)
	$var = getGeometricSingleSum($arrHeroes[$h][2] * (1  - $dogcogLevel * .02), 1.07, $arrHeroes[$h][1])
	$final = $var2 - $var
	return  $var2 - $var
 EndFunc
 Func getMaxLevel($gold,$factor, $base, $lev)
   $vartop = $lev - 1
   $varBottom = ExpertLog($gold * (1 - $base), $base)/($factor * (1  - $dogcogLevel * .02))
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
 Func getGeometricSingleSum($factor, $base, $second)
   $back = $base^($second)
   $bot = (1-$base)
   $final = ((1 - $back)/($bot))
   	return $factor * $final
 EndFunc
 Func verify150()
	$flag = 0
	$goldestimate = $gold
	for $var = 0 To $curHero + 1
	   if($arrHeroes[$var][1] < 150 And $goldestimate > 0) Then
		 $currentestimate = CalcHeroLevelsForGold($var, $goldestimate)
		 if($currentestimate + $arrHeroes[$var][1] > 150) Then
			$tempvalue = Mod ( $currentestimate + $arrHeroes[$var][1], 150 )
			$reduce = Floor ( ($currentestimate + $arrHeroes[$var][1])/ 150 )
			if($reduce > 1) Then
				  $currentestimate = 150 - $arrHeroes[$var][1]

			Else
				  $currentestimate = $currentestimate - $tempvalue
			EndIf

			$goldUsed = CalcHeroGoldCost($var, $currentestimate)
			$arrHeroes[$var][3] = $currentestimate
			$goldestimate= $goldestimate - $goldUsed
			$nexthero = $var
			_GUICtrlEdit_AppendText($editctrl2,"Level to 150: " & $arrHeroes[$var][1] & @CRLF)
			$upgradeCounter = 4
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
   Return
EndIf
EfficientBuy()
return;
EndFunc
;This will return 1 if either images are found, useful if you dont know if a hero is ascended.
Func checkTwoImages($image1, $image2, $waitTime, $left, $top, $right, $bottom,ByRef $x1,ByRef $y1, $similarity)
   $result = _WaitForImageSearchArea($image1, $waitTime, 1, $left, $top, $right, $bottom, $x1, $y1, $similarity)
   if($result = 0) Then
	  $result = _WaitForImageSearchArea($image2, $waitTime, 1, $left, $top, $right, $bottom, $x1, $y1, $similarity)
   EndIf
return $result
EndFunc
Func findHero($pos)
   Local $heroFound = 0
   Local $loopDown = 0
   Local $loopOverall = 0
   Local $foundButton = 0
   Local $waitTime = .4

   if $pos = 5 Or $pos = 7 Or $pos = 15 Or $pos = 17 Or $pos = 18 Or $pos = 20 Then
	  $waitTime = 1;
   EndIf

   While ($loopOverall < 5)
	  ;normal heroes will probably be found more
	  $result = checkTwoImages("images/heroes/normal/" & $arrHeroes[$pos][0], "images/heroes/gild/" & $arrHeroes[$pos][0], $waitTime, $left, $top + 173, $left + $width / 2,  $top + 590, $x1, $y1, 60)
	  If $result = 1 Then
		 ;_GUICtrlEdit_AppendText($editctrl,"Found Hero " & $arrHeroes[$pos][0] &@CRLF)
		 $HeroX = $x1
		 $HeroY = $y1
		 $lastHero = $pos
		 Return 1
	  Else
		 scrollTo($pos, $arrHeroes[$pos][0])

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


; Clicks the buy available upgrades box
Func clickUpgadeBox()
if($upgradeCounter > 0) Then
   scrollTo(-1, "images/buyAvailableUpgrades.png")
   Sleep(300)
   ;_GUICtrlEdit_AppendText($editctrl,"Scrolled " & $x1 & " " & $y1 &@CRLF)
   $result = _ImageSearchArea("images/buyAvailableUpgrades.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   If $result = 1 Then
	  ;_GUICtrlEdit_AppendText($editctrl,"Found Button " & $x1 & " " & $y1 &@CRLF)
		 clickMouseScreen($x1,$y1, "Left")
   EndIf
   $lastHero = $curHero
   $upgradeCounter = $upgradeCounter - 1
   Sleep(300)
EndIf
EndFunc

; Finds and clicks the ascend button to restart
Func Ascend()
   if($ascend <> 1) Then
	  Return
   EndIf
   if($waitFish == 1 And $foundFish == 0) Then
	  Return
   EndIf

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

   findHero(19)

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

		 $ascend = 0
	  Else
		_GUICtrlEdit_AppendText($editctrl,"Didnt Find Ascend Yes Button" & @CRLF)
	  EndIf
   Else
		_GUICtrlEdit_AppendText($editctrl,"Didnt Find Ascend" & @CRLF)
   EndIf

EndFunc

;Gets New Game Going
Func newGame()
   checkFarmState()
   clickFish()
$result = 0
$result2 = 0
   While($result2=0)
	  ; Gets the bounding rectangle of clicker heroes every 15 ticks
	  If Mod($timeMain,45) = 0 Then
		 checkScreen()
	  EndIf

	  ; Checks the farm button state every 60 ticks
	  If Mod($timeMain,30) = 0 Then
		 checkFarmState()
	  EndIf

	  getGold()
	  if($gold > 50 * ( 1 - $dogcogLevel * .02)) then
		 result = 1
	  EndIf

	  if $result = 0 Then

		 ; Extra clicks happen at the beginning to makes sure that a hero can be found when the ticks start again
		 For $clicks = 0 To 4 Step 1
			$lastClick = TimerInit()
			ControlClick($handle,"", "", "Left",1,$left + ($width / 1.2 ), $top + (($height) / 2))
		 Next
	  EndIf
	  ;Attempt to Hire Cid


   WEnd
   $curhero = 1
EndFunc

; Auxiliary functions for pausing the script, exiting and keeping it running while there is no activity
Func pause()
   While ($i = 0)
	  Sleep(30)
   WEnd
EndFunc

Func end()
   _MemoryClose($ID)
   Exit
EndFunc

While $i = 0
   Sleep(100)
WEnd
