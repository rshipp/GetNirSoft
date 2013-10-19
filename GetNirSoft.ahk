#NoEnv
SetWorkingDir %A_ScriptDir%
#SingleInstance, Force
ViewMode := "Report"

Gui, Font, s9 q5, Segoe UI
Gui, Add, Button, x10 y10 Default Center h30 gGetNirUtilsList vGetButton, Download List of NirSoft Utilities
Gui, Add, Button, x200 y10 Center h30 gChangeViewMode, View Mode
Gui, Add, Button, x495 y10 Center h30 gDownload, Download Selected
Gui, Add, ListView, x10 y50 h450 w600 Checked vNirListView, |Name                              |Version     |Last Updated
Gui, Show, , GetNirSoft
Return


GetNirUtilsList:
GuiControl, , GetButton, Please Wait...
TimeStamp := A_Now
URLDownLoadToFile, http://nirsoft.net/panel/, getnirsoft_panel_%TimeStamp%.tmp
FileRead, NirPanelData, getnirsoft_panel_%TimeStamp%.tmp
FileDelete, getnirsoft_panel_%TimeStamp%.tmp
If Not RegexMatch(NirPanelData, "NirSoft\sUtilities\sPanel")
{
	MsgBox, Error getting NirSoft utilities list. `nMaybe you are not connected to the internet?
	GuiControl, , GetButton, Download List of Nirstoft Utilities
	Return
}
LV_Delete()
SILID := IL_Create(1, 1, 0)
LILID := IL_Create(1, 1, 1)
LV_SetImageList(SILID)
IcoNumber = 0
Loop
{
	If RegexMatch(NirPanelData, "iU)<area\shref")
	{
		RegExMatch(NirPanelData, "siU)<area\shref=.(.*)\.exe.\salt=.(.*)\sv(\d*\.\d*).\sLast\sUpdated\sOn\s(\d+/\d+/\d+).\stitle", NirAppVar)
		NirPanelData := RegExReplace(NirPanelData, "siU)<area\shref", "", "", 1)
		IcoNumber++
		IconFile := "images\" . NirAppVar1 . ".png"
		ExeFile%IcoNumber% := NirAppVar1 . ".exe"
		IfExist, %IconFile%
		{
			IL_Add(SILID, IconFile, 0xF8F8F8, 1)
			IL_Add(LILID, IconFile, 0xF8F8F8, 1)
			LV_Add("Icon" . IcoNumber, "", NirAppVar2, NirAppVar3, ConvDate(NirAppVar4))
		}
		IfNotExist, %IconFile%
		{
			IfExist, extend.ini
			{
				;IniRead, 
				IconFile := ""
				IL_Add(SILID, IconFile, 1, 1)
				IL_Add(LILID, IconFile, 1, 1)
				LV_Add("Icon" . IcoNumber, "", NirAppVar2, NirAppVar3, ConvDate(NirAppVar4))
			}
			IfNotExist, extend.ini
			{
				IconFile := "shell32.dll"
				IL_Add(SILID, IconFile, 1, 1)
				IL_Add(LILID, IconFile, 1, 1)
				LV_Add("Icon" . IcoNumber, "", NirAppVar2, NirAppVar3, ConvDate(NirAppVar4))
			}
		}
	}
	Else
		break

	LV_ModifyCol()
}

NirPanelData = 
GuiControl, , GetButton, Update List of Nirstoft Utilities
Return



ChangeViewMode:
If ViewMode = Report
{
	GuiControl, -List +Icon, NirListView
	LV_SetImageList(LILID)
	ViewMode := "Icon"
}
Else If ViewMode = Icon
{
	GuiControl, -Icon +Report, NirListView
	LV_SetImageList(SILID)
	ViewMode := "Report"
}
Return





Download:
Gui, Submit, NoHide
Gui, 2:+owner1
Gui, 2:Font, s9 q5, Segoe UI
Gui, 2:Add, Text, , Downloading selected programs...
Gui, 2:Add, Edit, h100 w180 vProgram ReadOnly, 
Gui, 2:Show, h155 w200, Download Progress
RowNumber = 0  ; This causes the first loop iteration to start the search at the top of the list.
Loop
{
	RowNumber := LV_GetNext(RowNumber, "Checked")  ; Resume the search at the row after that found by the previous iteration.
	If Not RowNumber  ; The above returned zero, so there are no more selected rows.
	{
		Gui, 2:Add, Text, , All downloads complete!
		break
	}
	File := ExeFile%RowNumber%
	GetFile := "http://nirsoft.net/panel/" . File
	LV_GetText(GetProgram, RowNumber, 2)
	UrlDownloadToFile, %GetFile%, %File%
	Program := Program . GetProgram . "... Done.`n"
	GuiControl, 2:, Program, %Program%
}
Return

2GuiClose:
Gui, 2:Destroy
Return






GuiClose:
ExitApp
Return













ConvDate(Date) { 	;Convert date from DD/MM/YYYY to YYYY-MM-DD format for easy listview sorting.
	RegExMatch(Date, "../../(....)", Year)
	RegExMatch(Date, "../(..)/....", Month)
	RegExMatch(Date, "(..)/../....", Day)
	Return, Year1 . "-" . Month1 . "-" . Day1
}