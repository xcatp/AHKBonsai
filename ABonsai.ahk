#Include _lib\Extend.ahk


#Include buffer\cellData.ahk
#Include buffer\buffer.ahk
#Include render\render.ahk

ESC:: ExitApp()


bk := '272933'

g := Gui('AlwaysOnTop -Caption +ToolWindow +Border')
g.SetFont('s14', 'consolas')
g.MarginX := 0, g.MarginY := 0, g.BackColor := bk

normal := BufferLines()
normal.fillViewportRows(CellData('b7b7b7', bk, A_Space, false, ''))

renderLines()

gw := CW * tW, gh := CH * tH
g.Show(Format('w{} h{}', gw, gh))

#Include aBonsai\bonsai.ahk

config.live := 1
config.timeStep := 40
; config.seed := 83 ;2708
config.leaves := ['#', '&', '*']
config.infinite := 0
main(normal, config)

OnMessage(0x0201, (*) => PostMessage(0xA1, 2))

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
  updateLines()
}