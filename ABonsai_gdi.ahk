#Include _lib\Extend.ahk

#Include buffer\cellData.ahk
#Include buffer\buffer.ahk
#Include render\gdi_render.ahk
#Include aBonsai\parse.ahk

ESC:: ExitApp()

parseResult := Parse(A_Args.join(A_Space))
if !parseResult.valid {
  MsgBox parseResult.msg
  return
}

bk := '272933', border := 'a0a0a0'

#Include aBonsai\bonsai.ahk

InitConfig(parseResult.parsed)

gw := CW * tW, gh := CH * tH, defaultFillAttr := CellData('ffffff', bk, ' ', false, '')
g := Gui('AlwaysOnTop -Caption +ToolWindow +E0x00080000')
g.Show(Format('x{} y{}', (A_ScreenWidth - gw) // 2, (A_ScreenHeight - gh) // 2))
FrameShadow(g.Hwnd)

normal := BufferLines()
normal.fillViewportRows(defaultFillAttr)
updateScreen(0)

OnMessage(0x0201, (*) => PostMessage(0xA1, 2))

main(normal, config)

g.OnEvent('ContextMenu', OnContext)

OnContext(g, *) {
  m := Menu()
  m.Add('regrow', (*) => (config.seed := 0, main(normal, config)))
  m.Add('print', PrintC)
  m.Add('help', (*) => printHelp(normal))
  m.Add('exit', (*) => ExitApp())
  m.Show()
}

PrintC(*) {
  str := ''
  loop tH {
    str .= normal.getLineStr(A_Index, false, 1, tW) '`n'
  }
  A_Clipboard := str
  printMsg(normal, 'Saved to clipboard!')
  updateScreen(0)
}

FrameShadow(hwnd) {
  DllCall("dwmapi\DwmExtendFrameIntoClientArea", "ptr", hwnd, "ptr", Buffer(16, -1))
  DllCall("dwmapi\DwmSetWindowAttribute", "ptr", hwnd, "uint", 2, "int*", 2, "uint", 4)
}