[General]
SyntaxVersion=2
MacroID=ac7b8112-41d1-4582-8d01-76195e094004
[Comment]

[Script]
Function InitWindow() 
	WindowW = 580
	WindowH = 1040

	Hwnd = Plugin.Window.Find("kaopu001_kpzsEmuFrame8", "靠谱助手 - 天天模拟器")
	If Hwnd > 0 Then 
		Call Plugin.Window.Move(Hwnd, 0, 0)
		Delay 200
		Call Plugin.Window.Size(Hwnd, WindowW, WindowH)
		Delay 200
		Call Plugin.Window.Show(Hwnd)	
		Delay 200
		Call Plugin.Window.Top(Hwnd, 0)
		Delay 200
		LogStart "D:\my.log"
	End If
End Function


Function InputX(x, timeout, res2)
	Dim x0, x1, x2
	MoveTo 250, 72              '移动到x输入框
	Delay 100
	LeftClick 1	
	
	x0 = x \ 100
	x1 = (x - x0 * 100) \ 10
	x2 = (x - x0*100 - x1*10)
	' MsgBox "x " & x & " x0 " & x0 & " x1 " & x1 & " x2 " & x2
	
	If x >= 100 Then 
		KeyPress CStr(x0), 1
		Delay 100
	End If
	If x >= 10 Then
		KeyPress CStr(x1), 1
		If timeout > 0 Then 
			Delay timeout
		End If
		Delay 100
	End If
	KeyPress CStr(x2), 1
	Delay 200

	If timeout > 0 Then 
		Delay timeout
	End If

	KeyPress "Y", 1
	If timeout > 0 Then 
		Delay timeout
	Else 
		Delay 500
	End If		
End Function

Function InputY(y)
	Dim y0, y1, y2
	Dim yc

	MoveTo 370, 72              '移动到y输入框
	Delay 50
	LeftClick 1
	Delay 100
	
	y0 = y \ 100
	y1 = (y - y0 * 100) \ 10
	y2 = (y - y0*100 - y1*10)

	' MsgBox "y " & y & " y0 " & y0 & " y1 " & y1 & " y2 " & y2
	If y0 > 0 Then 
		yc = Chr(y0  + 65)
		KeyPress CStr(yc), 1
		Delay 50
	End If
	yc = Chr(y1  + 65)
	KeyPress CStr(yc), 1
	Delay 50
	
	yc = Chr(y2  + 65)
	KeyPress CStr(yc), 1
	Delay 50
	
	KeyPress "Z", 1
	Delay 50	
End Function

Function Search()
	MoveTo 464, 72               '查找
	LeftClick 1
	Delay 50
End Function


Function MoveToCenterAndClick()
	CenterX = 264
	CenterY = 480

	MoveTo CenterX, CenterY
	Delay 50
	LeftClick 1
End Function

Function CloseIfEmpty(x, y)
	c_red = "001262"

	FindColorEx 125, 545, 139, 575, c_red, 0, 0.9, intX, intY
	If intX > 0 and intY > 0 Then 
		TracePrint x & "," & y & " is empty place"
		IsEmptyPlace = True
		
		Delay 50
		KeyPress "Q", 1            ' Cancel
		Delay 100
	Else 
		IsEmptyPlace = False
	End If
End Function

Function Detect(x, y, res)
	Call MoveToCenterAndClick
	
	retry_cnt = 0		
	Rem Retry
	Delay 300
	
	IfColor 450, 450, "292504", 0 Then
		MoveTo 264, 610   '侦查 
		Delay 50
		LeftClick 1
		Delay 250
		
		MoveTo 368, 552   '确认
		Delay 50
		LeftClick 1
		Delay 250
		
		FindColorEx 111, 287, 172, 302, "0606E0", 0, 0.9, intX, intY
		If intX > 0 and intY > 0 Then 
			KeyPress "U", 1
			Delay 1000
			TracePrint "======= Found ======= " & x &" "&y 
			MsgBox "Found " & x &" "&y 			
		End If
	Else 
		retry_cnt = retry_cnt + 1
		If retry_cnt < 4 Then 
			TracePrint "Retry " & retry_cnt
			Goto Retry
		End If
	End If
	
	Call CloseIfEmpty(x,y)

	FindColorEx 35, 915, 50, 940, "001260", 0, 0.9, intX, intY
	If intX > 0 Then 
		TracePrint "Delete Mail"
		MoveTo 70, 918'删除邮件
		Delay 50
		LeftClick 1
		Delay 250	
	End If
	
	IfColor 380, 380, "353200", 0 Then
		TracePrint "Input Verify code"
		EndScript
	End If
End Function

