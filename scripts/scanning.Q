[General]
SyntaxVersion=2
BeginHotkey=121
BeginHotkeyMod=0
PauseHotkey=0
PauseHotkeyMod=0
StopHotkey=123
StopHotkeyMod=0
RunOnce=1
EnableWindow=
MacroID=3e9d65d5-08e6-4f77-b10b-ba26d6cd9078
Description=scanning
Enable=0
AutoRun=0
[Repeat]
Type=0
Number=1
[SetupUI]
Type=2
QUI=
[Relative]
SetupOCXFile=
[Comment]

[Script]
Function ProcessFile()
	Dim FileLine, MyLines
	
	Text = InputBox("输入文件名及开始搜索行号，以空格分隔：", "Label")
	FileLine = Split(Text, " ")
	path = "D:\" & FileLine(0) & ".txt"
	start = CInt(FileLine(1))
	Ret = MsgBox("文件路径为:" & path & ", 起始行号为:" & start, vbOKCancel)
	If Ret <> vbOK Then 
		EndScript
	End If


	LastX = 0
	Content = Plugin.File.ReadFileEx(path)	
	MyLines = Split(Content, "|")   

	For i = start To UBound(MyLines) - 1
		line = MyLines(i)
		If Len(line) > 0 Then 
			TracePrint "Got line(" & i & "):  "&line
			xy = Split(line, " ")
			x = CInt(xy(0))
			y = CInt(xy(1))
			TracePrint "Searching " & x & " " & y
			
			If LastX <> x Then 
				Call Lib.My.InputX(x, 300, 0)
				TracePrint "X change from " & LastX &" to " & x
			End If
			
			Call Lib.My.InputY(y)
			Call Lib.My.Search()
			If LastX <> x Then 
				LastX = x
				Delay 1000
			End If
			
			Delay 200
			Call Lib.My.Detect(x, y, 0)			
		End If

		Rem Continue
	Next
End Function

Call Lib.My.InitWindow()
Call ProcessFile()


