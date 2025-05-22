#Include _lib\Extend.ahk

#Include buffer\cellData.ahk
#Include buffer\buffer.ahk
#Include render\render.ahk
#Include aBonsai\parse.ahk

ESC:: ExitApp()

parseResult := Parse(A_Args.join(A_Space))
if !parseResult.valid {
  MsgBox parseResult.msg
  return
}

bk := '272933'

#Include aBonsai\bonsai.ahk

InitConfig(parseResult.parsed)

gw := CW * tW, gh := CH * tH, defaultFillAttr := CellData('ffffff', bk, ' ', false, '')
g := Gui('AlwaysOnTop -Caption +ToolWindow +Border')
g.SetFont('s14', 'consolas')
g.MarginX := 0, g.MarginY := 0, g.BackColor := bk

normal := BufferLines()
normal.fillViewportRows(defaultFillAttr)
renderLines()

g.Show(Format('w{} h{}', gw, gh))

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