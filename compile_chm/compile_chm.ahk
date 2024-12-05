/*
本AHK由 黑钨重工 在原版基础上修改 免费开源
所有开源项目 https://github.com/Furtory
仅适用于封装V1版本的chm帮助文档 V2版本帮助文档请到此链接下载https://wyagd001.github.io/
本封装源来自于https://github.com/wyagd001/wyagd001.github.io/tree/master
AHK正版官方论坛https://www.autohotkey.com/boards/viewforum.php?f=26
国内唯一完全免费开源AHK论坛请到QQ频道AutoHotKey12
本人所有教程和脚本严禁转载到此论坛以防被用于收费盈利 https://www.autoahk.com/
*/

#NoEnv
SetBatchLines, -1

if (A_PtrSize = 8) {
    try
    {
        AhkPath:=StrReplace(A_AhkPath, "\AutoHotkeyU64.exe" , "")
        RunWait "%AhkPath%\AutoHotkeyU32.exe" "%A_ScriptFullPath%"
    }
    catch
        MsgBox 16,, %AhkPath% This script must be run with AutoHotkey 32-bit, due to use of the ScriptControl COM component.
    ExitApp
}

OldWorkingDir:=StrReplace(A_ScriptFullPath, "\compile_chm\compile_chm.ahk" , "")
PtrSize:=A_PtrSize*8
FileSelectFolder, NewWorkingDir , %OldWorkingDir% , 0 , 当前运行的AHK版本:%PtrSize%位`n请选择解压后的目录
SetWorkingDir %NewWorkingDir%

hhc := A_WorkingDir "\hhc.exe"

FileRead IndexJS, %A_WorkingDir%\wyagd001.github.io-master\zh-cn\docs\static\source\data_index.js
Overwrite(A_WorkingDir "\chm_output\Index.hhk", INDEX_CreateHHK(IndexJS))

FileDelete, docs\static\content.js
FileRead TocJS, %A_WorkingDir%\wyagd001.github.io-master\zh-cn\docs\static\source\data_toc.js
Overwrite(A_WorkingDir "\chm_output\Contents.hhc", TOC_CreateHHC(TocJS))
IniWrite, Contents.hhc, Project.hhp, OPTIONS, Contents file
IniWrite, % "AutoHotkey Help,Contents.hhc,Index.hhk,docs\AutoHotkey.htm,docs\AutoHotkey.htm,,,,,0x73520,,0x10200e,[200,0,1080,700],0,,,,0,,0", Project.hhp, WINDOWS, Contents

FileCreateDir, %A_WorkingDir%\chm_output\docs
FileCopyDir, %A_WorkingDir%\wyagd001.github.io-master\zh-cn\docs, %A_WorkingDir%\chm_output\docs\, 1
FileCopy, %A_WorkingDir%\wyagd001.github.io-master\zh-cn\Project.hhp, %A_WorkingDir%\chm_output, 1
Run %A_WorkingDir%\chm_output
RunWait %A_WorkingDir%\chm_output\Project.hhp
Return

Overwrite(File, Text)
{
    FileOpen(File, "w").Write(Text)
}

TOC_CreateHHC(data)
{
    ComObjError(false)
    sc := ComObjCreate("ScriptControl")
    sc.Language := "JScript"
    sc.ExecuteStatement(data)
    output =
    ( LTrim
    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
    <html>
    <body>
    <object type="text/site properties">
    <param name="Window Styles" value="0x800025">
    <param name="ImageType" value="Folder">
    </object>
    )
    output .= TOC_CreateListCallback("", sc.Eval("tocData"))
    output .= "`n</body>`n</html>`n"
    return % output
}

TOC_CreateListCallback(byref output, data)
{
    output .= "`n<ul>`n"
    Loop % data.length
    {
        i := A_Index - 1

        output .= "<li><object type=""text/sitemap"">"

        if data[i][0]
        {
            Transform, param_name, HTML, % data[i][0]
            output .= "<param name=""Name"" value=""" param_name """>"
        }
        if data[i][1]
        {
            Transform, param_local, HTML, % data[i][1]
            output .= "<param name=""Local"" value=""docs/" param_local """>"
        }

        output .= "</object>"

        if data[i][2]
            output .= TOC_CreateListCallback(output, data[i][2])

        output .= "`n"
    }
    output .= "</ul>"
    return % output
}

INDEX_CreateHHK(data)
{
    ComObjError(false)
    sc := ComObjCreate("ScriptControl")
    sc.Language := "JScript"
    sc.ExecuteStatement(data)
    data := sc.Eval("indexData")
    output =
    ( LTrim
    <!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML//EN">
    <html>
    <body>
    )
    output .= "`n<ul>`n"
    Loop % data.length
    {
        i := A_Index - 1

        output .= "<li><object type=""text/sitemap"">"

        Transform, param_name, HTML, % data[i][0]
        output .= "<param name=""Name"" value=""" param_name """>"
        Transform, param_local, HTML, % data[i][1]
        output .= "<param name=""Local"" value=""docs/" param_local """>"

        output .= "</object>`n"
    }
    output .= "</ul>"
    output .= "`n</body>`n</html>`n"
    return % output
}