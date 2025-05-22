#Include _lib\Extend.ahk

#Include buffer\cellData.ahk
#Include buffer\buffer.ahk
#Include render\gdi_render.ahk

ESC:: ExitApp()

bk := '272933', border := 'a0a0a0'

gw := CW * tW, gh := CH * tH
g := Gui('AlwaysOnTop -Caption +ToolWindow +E0x00080000')
g.Show(Format('x{} y{}', (A_ScreenWidth - gw) // 2, (A_ScreenHeight - gh) // 2))
FrameShadow(g.Hwnd)

normal := BufferLines()
normal.fillViewportRows(CellData('ffffff', bk, ' ', false, ''))
updateScreen(0)

#Include aBonsai\bonsai.ahk
OnMessage(0x0201, (*) => PostMessage(0xA1, 2))

config.live := 1
config.timeStep := 0
config.seed := 83
config.leaves := ['#', '&', '*']
config.infinite := 0
main(normal, config)


g.OnEvent('ContextMenu', OnContext)

OnContext(g, *) {
  m := Menu()
  m.Add('regrow', (*) => (config.seed := 0, main(normal, config)))
  m.Add('print', PrintC)
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
