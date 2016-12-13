Function Capture(x, y, debug)
	up_x = 60
	up_y = 410
	down_x = 335
	down_y = 500
	CenterX = 264
	CenterY = 480
	Dim retry_cnt

	c_blue = "292504"
	c_red = "001262"
	coord = x&"_"&y

	Dim c0, c1, c2

	MoveTo CenterX, CenterY
	Delay 50
	LeftClick 1
	retry_cnt = 0

	Rem Retry
	Delay 150
	If retry_cnt > 12 Then
		TracePrint "Stop Retry: " & coord
		Exit Function
	End If

	c0 = GetPixelColor(464, 418)
	c1 = GetPixelColor(400, 482)
	c2 = GetPixelColor(130, 560)


	infostr = coord
	Ret0 = StrComp(c0, c_blue)
	If Ret0 = 0 Then
		Ret1 = StrComp(c0, c1)
		If Ret0 = Ret1 Then
			Ignore=0
			IfColor 105, 462, c_blue, 0 Then
				Ignore=1
				infostr = infostr & " -Ingoreing cond:1"
			End If
			FindColorEx 285, 400, 310, 480, "13D280", 0, 0.5, intX, intY
			If IntX < 0 Then
				Ignore=2
				infostr = infostr & " -Ingoreing cond:2"
			Else
				infostr = infostr & " -Ingoreing cond:0"
				Ingore=0
			End If

			If Ignore < 1 Then
				infostr = infostr & " +Found"
				path = "D:\pic\" & x & "\" & coord
				Plugin.Pic.PrintScreen up_x, up_y, down_x, down_y, path
			End If
			TracePrint infostr
		Else
			TracePrint "Is a Player: " &coord
		End If
		Delay 50
		KeyPress "X", 1
	Else
		FindColorEx 125, 545, 139, 575, c_red, 0, 0.9, intX, intY
		If intX < 0 Then
			TracePrint "Retry..."
			retry_cnt = retry_cnt+1
			Goto Retry
		End If
		TracePrint "Empty"
		Delay 50
		KeyPress "Q", 1
	End If

	Delay 200
End Function


Dim X, Y
TX = Plugin.File.ReadINI("coord", "x", "D:\config.ini")
TY = Plugin.File.ReadINI("coord","y","D:\config.ini")
X = Int(TX)
Y = Int(TY)


Call Lib.My.InitWindow()
MsgBox "Last Search Position: (" & X & "," & Y &")"

For i=X To 599
	Call Lib.My.InputX (i, 500, 0)
	Call Plugin.File.WriteINI("coord", "x", CStr(i), "D:\config.ini")
	For j=Y To 599
		Call Lib.My.InputY(j)
		Call Lib.My.Search()

		If j = 1 Then
			TracePrint "Y=1 Wait a memont"
			Delay 1000
		End If

		Call Capture(i, j, 0)
		Call Plugin.File.WriteINI("coord", "y", CStr(j), "D:\config.ini")
	Next
	Y = 1
Next
