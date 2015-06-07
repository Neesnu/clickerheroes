#include <ImageSearch.au3>
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

; Extra HotKeys
HotKeySet("{~}", "showAll")
HotKeySet("{!}", "checkFarmState")
HotKeySet("{@}", "levelUpBulk")
HotKeySet("{#}", "setTHLReached")
HotKeySet("{$}", "setAscendBaseReached")
HotKeySet("{%}", "checkHeroSouls")
HotKeySet("{^}", "Ascend")

; Makes sure that only one copy of this program can be running at once.
If _Singleton("ClickerHeroesBot", -1) = 0 Then
   Exit
EndIf

Global $timeMain = 0
Global $i = 0

; Game location properties
Global $left=0
Global $top=0
Global $right=0
Global $bottom=0

$x1=0
$y1=0
$x2=0
$y2=0

Global $ascendBaseReached = False

$Form1 = GUICreate("Logs", 550, 350)
Global $editctrl = GUICtrlCreateEdit("", 10, 10, 200, 330)
Global $editctrl2 = GUICtrlCreateEdit("", 250, 10, 200, 330)
GUICtrlSetLimit($editctrl,10000000)
GUICtrlSetLimit($editctrl2,10000000)

GUISetState(@SW_SHOW)

;Global $arrHeroes[26]=[DllStructCreate("dword HeroName;wchar Token[100]"),DllStructCreate("dword HeroLevel;wchar Token[100]"),]
Global $arrHeroes[30][4]= _
		[ _
		["cid.png",0,10,900],["tree.png",0,10,900],["ivan.png",0,10,900], _
		["brittany.png",0,10,800],["fish.png",0,10,800], ["betty.png",0,10,800], _
		["samurai.png",0,10,700], ["leon.png",0,10,700], ["forest.png",0,10,700], _
		["alexa.png", 0,10,700], ["natalia.png",0,10,700], ["mercedes.png",0,10,600], _
		["bobby.png", 0,10,600], ["broyle.png",0,10,600], ["george.png",0,10,600], _
		["king.png",0,25,500], ["jerator.png",0,25,500], ["abaddon.png",0,25,500], _
		["zhu.png",0,25,400], ["amen.png",0,25,400], ["beast.png",0,25,400], _
		["athena.png",0,25,300], ["aphrodite.png",0,25,200], ["shinatobe.png",0,25,100], _
		["grant.png",0,25,100], ["frostleaf.png",0,100,100], ["temp.png",0,0,0], _
		["temp.png",0,0,0], ["temp.png",0,0,0], ["temp.png",0,0,0] _
		]
Global $curHero = 0
Global $result = 0
Global $hTimer = TimerInit();

showAll()
;setHero()

;Sets Initial Hero Levels
Func setHero()
   _GUICtrlEdit_AppendText($editctrl,"setHero")
   ;Set to CurHero
   $curHero=4
   ;Cid
   $arrHeroes[0][1]= 10
   ;Tree
   $arrHeroes[1][1]= 10
   ;Ivan
   $arrHeroes[2][1]= 10
   ;Brittany
   $arrHeroes[3][1]= 10
   ;Fisherman
   $arrHeroes[4][1]= 5
   #comments-start
   ;Betty
   $arrHeroes[5][1]= 10
   ;Samurai
   $arrHeroes[6][1]= 10
   ;Leon
   $arrHeroes[7][1]= 10
   ;Forest
   $arrHeroes[8][1]= 10
   ;Alexa
   $arrHeroes[9][1]= 10
   ;Natalia
   $arrHeroes[10][1]= 10

   ;Mercedes
   $arrHeroes[11][1]= 100
   ;Bobby
   $arrHeroes[12][1]= 100
   ;Fire
   $arrHeroes[13][1]= 100
   ;George
   $arrHeroes[14][1]= 100
   ;King
   $arrHeroes[15][1]= 100
   ;Jerator
   $arrHeroes[16][1]= 100
   ;Abaddon
   $arrHeroes[17][1]= 100
   ;Ma Zhu
   $arrHeroes[18][1]= 100
   ;Amenhotep
   $arrHeroes[19][1]= 25
   ;Beastlord
   $arrHeroes[20][1]= 25
   ;Athena
   $arrHeroes[21][1]= 25
   ;Aphrodite
   $arrHeroes[22][1]= 25
   ;Shinatobe
   $arrHeroes[23][1]= 25
   ;Grant
   $arrHeroes[24][1]= 25
   ;FrostLeaf
   $arrHeroes[25][1]= 8

   #comments-end
EndFunc

Func reset()
   _GUICtrlEdit_AppendText($editctrl,"reset"  & @CRLF)

   Local $iHours = 0, $iMins = 0, $iSecs = 0
   Local $iEnd = TimerDiff($hTimer)
   _TicksToTime($iEnd, $iHours, $iMins, $iSecs)
   _GUICtrlEdit_AppendText($editctrl2,"Time to Ascend: " & StringFormat("%02d:%02d:%02d", $iHours, $iMins, $iSecs)  & @CRLF)
   ; The main varibales are all reset back to the defaults
		 $timeMain = 0
		 $ascendBaseReached = False
		 checkScreen()
		 $hTimer = TimerInit();

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

Func runBot()
   ; Gets the bounding rectangle of clicker heroes
   checkScreen()

   Local $iHours = 0, $iMins = 0, $iSecs = 0
   Local $iEnd = TimerDiff($hTimer)
   _TicksToTime($iEnd, $iHours, $iMins, $iSecs)
   _GUICtrlEdit_AppendText($editctrl2,"Runbot: " & StringFormat("%02d:%02d:%02d", $iHours, $iMins, $iSecs) & @CRLF)
   _GUICtrlEdit_AppendText($editctrl2,"PLEASE PRESS F10 TO STOP ME" & @CRLF)
   ;If we arnt starting with an override then start
   If $curHero = 0 Then
	  checkHeroes()
   EndIf
   ; Makes the script run indefinately
   While ($i = 0)

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
	  If Mod($timeMain,360) = 0 Then
		 checkFarmState() ;WORKING
	  EndIf

	  ; Checks for the upgrade box every 30 ticks
	  If Mod($timeMain,30) = 0 Then
		 clickUpgadeBox() ;WORKING
	  EndIf

	  ; Checks the ascend plus amount every 10 ticks
	  If $ascendBaseReached = true Then
			Ascend()
	  EndIf

	  ; Calls the level up method every tick
	  If Mod($timeMain,6) = 0 Then
		 levelUp()
	  EndIf

	  ; Find the fish!
	  If Mod($timeMain,3) = 0 Then
		 findFish()
	  EndIf

	  $timeMain = $timeMain + 1

	  ; A delay can be introduced into the tick so that everything will run slower
	  ;Sleep(500)
   WEnd
EndFunc

; Gets the bounding rectangle of clicker heroes
Func checkScreen()
   Local $aPos = WinGetPos("Clicker Heroes")

   $left = $aPos[0]
   $top = $aPos[1]
   $right = $left + $aPos[2]
   $bottom = $top + $aPos[3]

   ;_ImageSearchArea('check5.bmp', 1, left, top, right, bottom, $x, $y, 0)
EndFunc

; Checks that the farm state is still turned on
Func checkFarmState()
   Local $aCoord = PixelSearch($right - ($right/36), $bottom / 2.65 , $right, $bottom / 2.65 + ($right/36), 0xFF0000)
   if @error = 0 Then
	  ;MsgBox( 0, "checkFarmState", "Success!")
	  ;MouseClick("left", $right - 20, $bottom / 2.65 + 20,1,5)
	  Local $retCode = WinActivate("Clicker Heroes")
	  If $retCode <> 0 Then
		 ControlSend ("Clicker Heroes","","","{A}")
	  EndIf
   EndIf
EndFunc

Func findFish()
   ;Fish Find
   $result = _ImageSearchArea("images/fish.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	  If $result = 1 Then
		 ;MouseClick("left",$x1,$y1)
		 WinActivate("Clicker Heroes")
		 ControlClick("Clicker Heroes","", "", "Left",1,$x1,$y1)
		 Sleep(300)
		  _GUICtrlEdit_AppendText($editctrl2,"Fish Found!" & @CRLF)
	  EndIf
EndFunc
; Levels up a character if the gilded button is on screen
Func levelUp()
   _GUICtrlEdit_AppendText($editctrl,"levelUp Case " & $curHero & @CRLF)
   $x2 = 0
   $y2 = 0

   Switch ($curHero)
   Case 0
	  ;Attempt to Level Cid
	  $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[0][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 Then
			;MouseClick("left",$x2,$y2)
			WinActivate("Clicker Heroes")
			ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
			$arrHeroes[0][1]= $arrHeroes[0][1] + 1
			;MouseMove($x1,$y1)
			If $arrHeroes[0][1] >= 10 Then
			   $curHero = 1
			EndIf
		 EndIf
	  EndIf
   Case 1
	  ;Attempt to Level Treebeast
	  $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[1][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 Then
			;MouseClick("left",$x2,$y2)
			WinActivate("Clicker Heroes")
			ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
			$arrHeroes[1][1]= $arrHeroes[1][1] + 1
			;MouseMove($x1,$y1)
			If $arrHeroes[1][1] >= 10 Then
			   $curHero = 2
			EndIf
		 EndIf
	  EndIf
   Case 2
	  ;Attempt to Hire then Level Ivan
	  hireLevel(2)
   Case 3
	  ;Attempt to Hire then Level Brittany
	  hireLevel(3)
   Case 4
	  ;Attempt to Hire then Level Fish
	  findHero(4)
	  hireLevel(4)
   Case 5
	  ;Attempt to Hire then Level Betty
	  findHero(5)
	  hireLevel(5)
   Case 6
	  ;Attempt to Hire then Level Samurai
	  findHero(6)
	  hireLevel(6)
	  levelUp100()
   Case 7
	  ;Attempt to Hire then Level Leon
	  findHero(7)
	  hireLevel(7)
   Case 8
	  ;Attempt to Hire then Level Forest
	  findHero(8)
	  hireLevel(8)
   Case 9
	  ;Attempt to Hire then Level Alexa
	  findHero(9)
	  hireLevel(9)
   Case 10
	  ;Attempt to Hire then Level Natalia
	  findHero(10)
	  hireLevel(10)
   Case 11
	  ;Attempt to Hire then Level Mercedes
	  findHero(11)
	  hireLevel(11)
   Case 12
	  ;Attempt to Hire then Level Bobby
	  findHero(12)
	  hireLevel(12)
	  levelUp100()
   Case 13
	  ;Attempt to Hire then Level Broye Fire Mage
	  findHero(13)
	  hireLevel(13)
   Case 14
	  ;Attempt to Hire then Level George
	  findHero(14)
	  hireLevel(14)
   Case 15
	  ;Attempt to Hire then Level King Midas
	  findHero(15)
	  hireLevel(15)
   Case 16
	  ;Attempt to Hire then Level Jerator
	  findHero(16)
	  hireLevel(16)
   Case 17
	  ;Attempt to Hire then Level Abaddon
	  findHero(17)
	  hireLevel(17)
   Case 18
	  ;Attempt to Hire then Level Mu Zhu
	  findHero(18)
	  hireLevel(18)
	  levelUp100()
   Case 19
	  ;Attempt to Hire then Level Amenhotep
	  findHero(19)
	  hireLevel(19)
   Case 20
	  ;Attempt to Hire then Level Beastlord
	  findHero(20)
	  hireLevel(20)
   Case 21
	  ;Attempt to Hire then Level Athena
	  findHero(21)
	  hireLevel(21)
   Case 22
	  ;Attempt to Hire then Level Aphrodite
	  findHero(22)
	  hireLevel(22)
	  levelUp100()
   Case 23
	  ;Attempt to Hire then Level Shinatobe
	  findHero(23)
	  hireLevel(23)
   Case 24
	  ;Attempt to Hire then Level Grant
	  findHero(24)
	  hireLevel(24)
   Case 25
	  ;Attempt to Hire then Level Frostleaf
	  findHero(25)
	  hireLevel(25)
   Case 26
	  If $arrHeroes[24][1] >= $arrHeroes[24][3] Then
		 checkIfAscendBaseReached()
	  EndIf
	  levelUpBulk()
   Case Else
	  Msgbox(0,"Abort", "We are at Case Number which isnt coded yet: " & $curHero)
	  Exit
   EndSwitch


EndFunc

Func findHero($pos)
   _GUICtrlEdit_AppendText($editctrl,"findHero Hero: " & $arrHeroes[$pos][0] & @CRLF)
   ;Check if Previous Hero is Hired else Abort
   Local $heroFound = 0
   Local $loopDown = 0
   Local $loopOverall = 0
   Local $foundButton = 0
   ;First !
   If ($pos = 0) Then
	  While ($i = 0)
		 $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
		 If $result = 1 Then
			Local $result1, $result2, $result3, $result4
			Do
			   $result1 = _ImageSearchArea("images/hire2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   $result2 = _ImageSearchArea("images/hire.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   $result3 = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   $result4 = _ImageSearchArea("images/level2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   If $result1 = 1 or $result2 = 1 or $result3 = 1 or $result4 = 1 Then
				  _GUICtrlEdit_AppendText($editctrl,"Hero Found: " & $arrHeroes[$pos][0] & " Results " & $result1 & "|" & $result2 & "|" & $result3 & "|" & $result4 & @CRLF)
				  $foundButton = 1
				  ExitLoop
			   Else
				  WinActivate("Clicker Heroes")
				  MouseWheel("down")
				  MouseWheel("up",2)
			   EndIf

			Until (0 = 1)
		 Else
			WinActivate("Clicker Heroes")
			MouseWheel("up")
			$loopDown = $loopDown + 1
			$loopOverall = $loopDown + 1
			If $loopDown > 30 Then
			   ;Msgbox(0,"Test","We likely shouldnt be here")
			   WinActivate("Clicker Heroes")
			   MouseWheel("down",10)
			   Sleep(100)
			   $loopDown = 0
			EndIf
			If $loopOverall > 90 Then
			   Msgbox(0,"Test","This should never happen, something likely wrong with the image")
			   Exit
			EndIf
		 EndIf
		 If $foundButton = 1 Then
			ExitLoop
		 EndIf
	  Wend
   ;Other Heroes
   ElseIf ($arrHeroes[$pos-1][1] > 0) Then
	  While ($i = 0)
		 $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
		 If $result = 1 Then
			If $y1 < 200 Then
			   Msgbox(0,"Found","Found " & $arrHeroes[$pos][0] & " X:" & $x1 & " Y:" &$y1)
			   Exit
			EndIf
			Local $result1, $result2, $result3, $result4, $doOnce = 0
			Do
			   $result1 = _ImageSearchArea("images/hire2.png", 1, $left, $y1-($bottom/18), $x1, $y1 + ($bottom/9), $x2, $y2,60)
			   Sleep(100)
			   $result2 = _ImageSearchArea("images/hire.png", 1, $left, $y1-($bottom/18), $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   Sleep(100)
			   $result3 = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   Sleep(100)
			   $result4 = _ImageSearchArea("images/level2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)

			   If $result1 = 1 or $result2 = 1 or $result3 = 1 or $result4 = 1 Then
				  _GUICtrlEdit_AppendText($editctrl,"Hero Found: " & $arrHeroes[$pos][0] & " Results " & $result1 & "|" & $result2 & "|" & $result3 & "|" & $result4 & @CRLF)
				  $foundButton = 1
				  ExitLoop
			   Else
				  _GUICtrlEdit_AppendText($editctrl,"Found Hero, didnt find Button: " & $arrHeroes[$pos][0] & @CRLF)
				  If $doOnce = 0 Then
					 WinActivate("Clicker Heroes")
					 MouseWheel("up")
					 Sleep(200)
					 MouseWheel("down",2)
					 Sleep(300)
					 $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
					 Sleep(1500)
				  ElseIf $doOnce = 20 Then
					 _GUICtrlEdit_AppendText($editctrl,"Cant find button for hero trying one last time " & $arrHeroes[$pos][0] & @CRLF)
					 findhero($pos)
					 ExitLoop
				  EndIf
				  $doOnce = $doOnce + 1

			   EndIf

			Until (0 = 1)
		 Else
			_GUICtrlEdit_AppendText($editctrl,"Didnt Find Hero: " & $arrHeroes[$pos][0] & @CRLF)
			WinActivate("Clicker Heroes")
			MouseWheel("down")
			Sleep( 1000 )
			$loopDown = $loopDown + 1
			$loopOverall = $loopDown + 1
			If $loopDown > 30 Then
			   _GUICtrlEdit_AppendText($editctrl,"Cant find Hero, back to the top: " & $arrHeroes[$pos][0] & @CRLF)
			   WinActivate("Clicker Heroes")
			   MouseWheel("up",30)
			   $loopDown = 0
			   Sleep(500)
			EndIf
			If $loopOverall > 90 Then
			   Msgbox(0,"Test","This should never happen, something likely wrong with the image")
			   Exit
			EndIf
		 EndIf
		 If $foundButton = 1 Then
			ExitLoop
		 EndIf
	  Wend
   EndIf
EndFunc

Func hireLevel($pos)
   _GUICtrlEdit_AppendText($editctrl,"hireLevel" & @CRLF)
   ;Hire
	  If ($arrHeroes[$pos][1]= 0) Then
		 Sleep(100)
		;Msgbox(0,"Hiring","Now Hiring" & $arrHeroes[$pos][0])
		 $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
		 If $result = 1 Then
			Local $result1, $result2, $result3, $result4, $downOnce=0
			_GUICtrlEdit_AppendText($editctrl,"Found Normal Image: " & $arrHeroes[$pos][0] & @CRLF)
			Do
			   ;MouseMove($x1,$y1)
			   Sleep(100)
			   $result1 = _ImageSearchArea("images/hire2.png", 1, $left, $y1-($bottom/18), $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   Sleep(100)
			   $result2 = _ImageSearchArea("images/hire.png", 1, $left, $y1-($bottom/18), $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   Sleep(100)
			   $result3 = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)
			   Sleep(100)
			   $result4 = _ImageSearchArea("images/level2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 60)

			   If $result3 = 1 or $result4 = 1 Then
				  _GUICtrlEdit_AppendText($editctrl,"Hero is already leveled" & @CRLF)
				  $arrHeroes[$pos][1]= 1
				  ExitLoop
			   ElseIf $result1 = 1 Then
				  _GUICtrlEdit_AppendText($editctrl,"About to Hire Image: " & $arrHeroes[$pos][0] & @CRLF)
				  ;MouseClick("left",$x2,$y2)
				  WinActivate("Clicker Heroes")
				  ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
				  $arrHeroes[$pos][1]= 1
				  Sleep(100)
			   ElseIf $result2 = 1 Then
				  _GUICtrlEdit_AppendText($editctrl,"Taking a nap for 10s" & @CRLF)
				  ;Take a Nap and wait for Money
				  Sleep(10000)
			   Else
				  _GUICtrlEdit_AppendText($editctrl,"Didnt find hire image for hero " & $arrHeroes[$pos][0] & @CRLF)
				  If $downOnce = 0 Then
					 WinActivate("Clicker Heroes")
					 MouseWheel("down")
					 $downOnce = $downOnce + 1
					 Sleep(300)
					 $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
					 Sleep(1700)
				  Else
					 ;We are likely in a weird state, ABORT!
					 ExitLoop
				  EndIf
			   EndIf

			Until (0 = 1)
		 EndIf
	  EndIf
	  If ($arrHeroes[$pos][1] > 0) Then
		 ;Level
		 Local $intCounter = 0
		 Do
			$result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
			If $result = 1 Then
			   $result = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
			   If $result = 1 Then
				  ;MouseClick("left",$x2,$y2)
				  WinActivate("Clicker Heroes")
				  ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
				  $arrHeroes[$pos][1]= $arrHeroes[$pos][1] + 1
				  If $pos = 25 and ($arrHeroes[$pos][1] = 5 or $arrHeroes[$pos][1] = 20 or $arrHeroes[$pos][1] = 40 or $arrHeroes[$pos][1] = 60 or $arrHeroes[$pos][1] = 70) Then
						checkFarmState()
				  EndIf
				  If $arrHeroes[$pos][1] = 10 or $arrHeroes[$pos][1] = 15 or $arrHeroes[$pos][1] = 25 or $arrHeroes[$pos][1] = 50 or $arrHeroes[$pos][1] = 75  Then
					 If $pos = 25 Then
						WinActivate("Clicker Heroes")
						MouseWheel("up")
						Sleep(200)
						MouseWheel("down",2)
						Sleep(200)
						clickUpgadeBox()
					 Else
						clickUpgadeBox()
					 EndIf
					 checkFarmState()
				  EndIf
				 ;MouseMove($x1,$y1)
			   EndIf
			   If $arrHeroes[$pos][1] >= $arrHeroes[$pos][2]  Then
				  _GUICtrlEdit_AppendText($editctrl,"Levelup Complete for hero " & $arrHeroes[$pos][0] & @CRLF)
				  $curHero = $pos + 1
				  If $pos > 20 Then
					 MouseWheel("down",2)
					 clickUpgadeBox()
				  EndIf
			   EndIf
			   $intCounter = $intCounter + 1;
			EndIf
		 Until ($arrHeroes[$pos][1] >= $arrHeroes[$pos][2] or $intCounter > 120)
	  EndIf
EndFunc

; Checks to see if the base amount (8 or higher) of hero souls gained has been reached
Func checkIfAscendBaseReached()
   ; I put in multiple searches for the ascension amount since it can miss amounts if primal bosses make it jump
   ; more than 1 HS - Credit to Redditor 51Ry for this suggestionf
   $result8 = _ImageSearchArea("images/ascends/ascend8.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result9 = _ImageSearchArea("images/ascends/ascend9.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result10 = _ImageSearchArea("images/ascends/ascend10.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result11 = _ImageSearchArea("images/ascends/ascend11.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result12 = _ImageSearchArea("images/ascends/ascend12.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result13 = _ImageSearchArea("images/ascends/ascend13.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)
   $result14 = _ImageSearchArea("images/ascends/ascend14.png", 1, $left, $top, $right, $bottom, $x1, $y1, 70)
   Sleep(200)

   If $result8 = 1 Or $result9 = 1 Or $result10 = 1 Or $result11 = 1 Or $result12 = 1 Or $result13 = 1 Or $result14 Then
	  $ascendBaseReached = True
   EndIf
EndFunc

Func forceBuyUpgrade()
   MouseWheel("down",20)
   Sleep(300)
   MouseWheel("up")
   Sleep(300)
   MouseWheel("down",2)
   Sleep(15000) ;Accumulate Cash
   clickUpgadeBox()
   ;Move Back Up
   MouseWheel("up",20)
   Sleep(1000)
EndFunc
; Clicks the buy available upgrades box
Func clickUpgadeBox()
   ;MouseMove( $left, $top )
   Sleep(300)
   $result = _ImageSearch("images/buyAvailableUpgrades.jpg",1,$x1, $y1,85)
   If $result = 1 Then
		;MouseClick("left",$x1,$y1,1,5)
		 WinActivate("Clicker Heroes")
		 ControlClick("Clicker Heroes","", "", "Left",1,$x1,$y1)
   EndIf
EndFunc

; Goes through giving 100 levels to each of the heroes that are hired
Func levelUp100()
   ; ANY improvements would be awesome so code away
   WinActivate("Clicker Heroes")

   Local $doOnce = 0

   Local $intHeroCount =  UBound($arrHeroes, $UBOUND_ROWS)

   ; Fill the array with data.
    For $i = 0 To $intHeroCount - 5
      If $arrHeroes[$i+4][1] > 0 and $arrHeroes[$i][1] < 100 Then
		 If $doOnce = 0 Then
			MouseWheel("up",20)
			$doOnce = 1
			Sleep(300)
		 EndIf
		 findHero($i)
		 _GUICtrlEdit_AppendText($editctrl,"Leveling to 100 " & $arrHeroes[$i][0] & @CRLF)
		 Local $loopOnce = 0
		 Do
			$result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$i][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
			If $result = 1 Then
			   WinActivate("Clicker Heroes")
			   Sleep(100)
			   ControlSend ("Clicker Heroes","","","{Z DOWN}")
			   Sleep(100)
			   $result = _ImageSearchArea("images/level25.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)

			   If $result = 1 Then
				  ;MouseClick("left",$x2,$y2)
				  WinActivate("Clicker Heroes")
				  ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
				  $arrHeroes[$i][1]= $arrHeroes[$i][1] + 25
				  ;MouseMove($x1,$y1)
			   Else
				  If $loopOnce = 1 Then
					 WinActivate("Clicker Heroes")
					 If $i > 5 Then
						MouseWheel("up")
					 Else
						MouseWheel("down")
					 EndIf

					 Sleep(300)
					 $loopOnce = 1
				  EndIf
			   EndIf
			   ControlSend ("Clicker Heroes","","","{Z UP}")
			EndIf
		 Until ($arrHeroes[$i][1] >= 100)
		 _GUICtrlEdit_AppendText($editctrl,"Leveling to 100 Complete for " & $arrHeroes[$i][0] & @CRLF)
	  EndIf
   Next

   forceBuyUpgrade()
   checkFarmState()
EndFunc
; Goes through giving Array Position 3 levels (or the max it can) to each of the heroes
Func levelUpBulk()
   ; ANY improvements would be awesome so code away
   WinActivate("Clicker Heroes")

   Local $doOnce = 0

   Local $intHeroCount =  UBound($arrHeroes, $UBOUND_ROWS)

   ; Fill the array with data.
    For $i = 0 To $intHeroCount - 1
      If $arrHeroes[$i][1] > 0  and ($arrHeroes[$i][1] < $arrHeroes[$i][3]) Then
		 If $doOnce = 0 Then
			MouseWheel("up",20)
			$doOnce = 1
			Sleep(300)

		 EndIf
		 findHero($i)
		 _GUICtrlEdit_AppendText($editctrl,"Leveling up to Bulk " & $arrHeroes[$i][3] & "Hero: " & $arrHeroes[$i][0] & @CRLF)
		 Local $loopOnce = 0
		 Do
			$result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$i][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
			If $result = 1 Then
			   WinActivate("Clicker Heroes")
			   ControlSend ("Clicker Heroes","","","{CTRLDOWN}")
			   Sleep(100)
			   $result = _ImageSearchArea("images/level100.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
			   If $result = 1 Then
				  ;MouseClick("left",$x2,$y2)
				  WinActivate("Clicker Heroes")
				  ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
				  $arrHeroes[$i][1]= $arrHeroes[$i][1] + 100
				  ;MouseMove($x1,$y1)
			   Else
				  If $loopOnce = 1 Then
					 WinActivate("Clicker Heroes")
					 If $i > 5 Then
						MouseWheel("up")
					 Else
						MouseWheel("down")
					 EndIf
					 Sleep(300)
					 $loopOnce = 1
				  EndIf
			   EndIf

			   ControlSend ("Clicker Heroes","","","{CTRLUP}")
			EndIf
		 Until ($arrHeroes[$i][1] >= $arrHeroes[$i][3])
	  EndIf
    Next


   checkFarmState()
EndFunc

; Finds and clicks the ascend button to restart
Func Ascend()
   _GUICtrlEdit_AppendText($editctrl,"Trying to Ascend" & @CRLF)
   ;Move Up and Wait
   WinActivate("Clicker Heroes")
   MouseWheel("up",10)
   Sleep(500)

   ;Find Amen
   findHero(19)

   _GUICtrlEdit_AppendText($editctrl,"Found Amen" & @CRLF)
   MouseWheel("down")
   Sleep(500)
   $result =  _ImageSearchArea("images/ascend.bmp", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
   If $result = 1 Then
      _GUICtrlEdit_AppendText($editctrl,"Found Ascend" & @CRLF)
      WinActivate("Clicker Heroes")
	  MouseClick("left",$x1,$y1)
	  Sleep(500)
	  $result = _ImageSearchArea("images/ascendYes.png", 1, $left, $top, $right, $bottom, $x1, $y1, 120)
	  If $result = 1 Then
		 MouseClick("left",$x1,$y1,1,5)
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

   While($arrHeroes[1][1]=0)
	  ; Gets the bounding rectangle of clicker heroes every 15 ticks
	  If Mod($timeMain,45) = 0 Then
		 checkScreen() ;WORKING
	  EndIf

	  ; Checks the farm button state every 60 ticks
	  If Mod($timeMain,30) = 0 Then
		 checkFarmState() ;WORKING
	  EndIf

	  ; Extra clicks happen at the beginning to makes sure that a hero can be found when the ticks start again
	  WinActivate("Clicker Heroes")
	  For $clicks = 0 To 100 Step 1
		 ;MouseClickMouseClick("left",$left + ($right / 1.2 ), $top + (($bottom - $top) / 2))
		 ControlClick("Clicker Heroes","", "", "Left",1,$left + ($right / 1.2 ), $top + (($bottom - $top) / 2))
	  Next

	  ;Attempt to Hire Cid
	  $result = _ImageSearchArea("images/heroes/normal/cid.png", 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/hire2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 Then
			;MouseClick("left",$x2,$y2)
			WinActivate("Clicker Heroes")
			ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
			$arrHeroes[0][1]= 1
		 EndIf
	  EndIf
	  ;Attempt to Hire Treebeast
	  $result = _ImageSearchArea("images/heroes/normal/tree.png", 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/hire2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 Then
			;MouseClick("left",$x2,$y2)
			WinActivate("Clicker Heroes")
			ControlClick("Clicker Heroes","", "", "Left",1,$x2,$y2)
			$arrHeroes[1][1]= 1
		 EndIf
	  EndIf
   WEnd
EndFunc

Func checkHero($pos)

   If ($arrHeroes[$pos][1]= 0) Then
	  $result = _ImageSearchArea("images/heroes/normal/" & $arrHeroes[$pos][0], 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 $result = _ImageSearchArea("images/level.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 and $pos <> 25 Then
			$arrHeroes[$pos][1]= 1
			$curHero = $pos + 1
		 EndIf
		 $result = _ImageSearchArea("images/level2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 and $pos <> 25 Then
			$arrHeroes[$pos][1]= 1
			$curHero = $pos + 1
		 EndIf
	  EndIf
   EndIf

EndFunc

; Loads Hero List
Func checkHeroes()
do
   ;Onward and Upward!
   WinActivate("Clicker Heroes")
   MouseWheel("up", 30)

   If ($arrHeroes[0][1]= 0) Then
	  $result = _ImageSearchArea("images/heroes/normal/cid.png", 1, $left, $top, $right, $bottom, $x1, $y1, 60)
	  If $result = 1 Then
		 _GUICtrlEdit_AppendText($editctrl,"Found Cid Image" & @CRLF)
		 $result = _ImageSearchArea("images/Hire.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
		 If $result = 1 Then
			_GUICtrlEdit_AppendText($editctrl,"Found Cid Hire Image" & @CRLF)
			newGame()
		 Else
			_GUICtrlEdit_AppendText($editctrl,"Didnt find Cid Hire Image" & @CRLF)
			$result = _ImageSearchArea("images/hire2.png", 1, $left, $y1, $x1, $y1 + ($bottom/9), $x2, $y2, 120)
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
   ;If we dont have Cid its a New Game so Stop!
   If ($arrHeroes[0][1]= 0) Then
	  Msgbox(0,"","Cant find Cid, need to replace image.")
	  Exit
   EndIf

   ;Tree
   checkHero(1)

   If ($arrHeroes[1][1]= 0) Then
	  ExitLoop
   EndIf
   ;Ivan
   checkHero(2)

   If ($arrHeroes[2][1]= 0) Then
	  ExitLoop
   EndIf

   ;Brittany
   checkHero(3)
   If ($arrHeroes[3][1]= 0) Then
	  ExitLoop
   EndIf

   ;Fisherman
   findHero(4)
   checkHero(4)
   If ($arrHeroes[4][1]= 0) Then
	  ExitLoop
   EndIf

   ;Betty
   findHero(5)
   checkHero(5)
   If ($arrHeroes[5][1]= 0) Then
	  ExitLoop
   EndIf

   ;Samurai
   findHero(6)
   checkHero(6)
   If ($arrHeroes[6][1]= 0) Then
	  ExitLoop
   EndIf

   ;Leon
   findHero(7)
   checkHero(7)
   If ($arrHeroes[7][1]= 0) Then
	  ExitLoop
   EndIf

   ;Forest
   findHero(8)
   checkHero(8)
   If ($arrHeroes[8][1]= 0) Then
	  ExitLoop
   EndIf

   ;Alexa
   findHero(9)
   checkHero(9)
   If ($arrHeroes[9][1]= 0) Then
	  ExitLoop
   EndIf

   ;Natalia
   findHero(10)
   checkHero(10)
   If ($arrHeroes[10][1]= 0) Then
	  ExitLoop
   EndIf

   ;Mercedes
   findHero(11)
   checkHero(11)
   If ($arrHeroes[11][1]= 0) Then
	  ExitLoop
   EndIf

   ;Bobby
   findHero(12)
   checkHero(12)
   If ($arrHeroes[12][1]= 0) Then
	  ExitLoop
   EndIf

   ;Fire
   findHero(13)
   checkHero(13)
   If ($arrHeroes[13][1]= 0) Then
	  ExitLoop
   EndIf

   ;George
   findHero(14)
   checkHero(14)
   If ($arrHeroes[14][1]= 0) Then
	  ExitLoop
   EndIf

   ;King
   findHero(15)
   checkHero(15)
   If ($arrHeroes[15][1]= 0) Then
	  ExitLoop
   EndIf

   ;Jerator
   findHero(16)
   checkHero(16)
   If ($arrHeroes[16][1]= 0) Then
	  ExitLoop
   EndIf

   ;Abaddon
   findHero(17)
   checkHero(17)
   If ($arrHeroes[17][1]= 0) Then
	  ExitLoop
   EndIf

   ;Ma Zhu
   findHero(18)
   checkHero(18)
   If ($arrHeroes[18][1]= 0) Then
	  ExitLoop
   EndIf

   ;Amenhotep
   findHero(19)
   checkHero(19)
   If ($arrHeroes[19][1]= 0) Then
	  ExitLoop
   EndIf

   ;Beastlord
   findHero(20)
   checkHero(20)
   If ($arrHeroes[20][1]= 0) Then
	  ExitLoop
   EndIf

   ;Athena
   findHero(21)
   checkHero(21)
   If ($arrHeroes[21][1]= 0) Then
	  ExitLoop
   EndIf

   ;Aphrodite
   findHero(22)
   checkHero(22)
   If ($arrHeroes[22][1]= 0) Then
	  ExitLoop
   EndIf

   ;Shinatobe
   findHero(23)
   checkHero(23)
   If ($arrHeroes[23][1]= 0) Then
	  ExitLoop
   EndIf

   ;Grant
   findHero(24)
   checkHero(24)
   If ($arrHeroes[24][1]= 0) Then
	  ExitLoop
   EndIf

   ;FrostLeaf
   findHero(25)
   checkHero(25)

   #comments-start

   $arrHeroes[23].HeroName="SHINATOBE"
   $arrHeroes[23].HeroLevel=0

   $arrHeroes[24].HeroName="GRANT"
   $arrHeroes[24].HeroLevel=0

   $arrHeroes[25].HeroName="FROSTLEAF"
   $arrHeroes[25].HeroLevel=0
    #comments-end
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
	  Sleep(100)
   WEnd
EndFunc

Func end()
   Send("{CTRLUP}")
   Exit
EndFunc

While $i = 0
   Sleep(100)
WEnd
