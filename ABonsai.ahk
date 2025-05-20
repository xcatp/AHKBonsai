#Include _lib\Extend.ahk


#Include buffer\cellData.ahk
#Include buffer\buffer.ahk
#Include render\render.ahk

ESC:: ExitApp()


bk := '272933'

g := Gui('AlwaysOnTop -Caption +ToolWindow ')
g.SetFont('s14', 'consolas')
g.MarginX := 0, g.MarginY := 0, g.BackColor := bk

normal := BufferLines()
normal.fillViewportRows(CellData('b7b7b7', bk, '', false, ''))

renderLines()

gw := CW * tW, gh := CH * tH
g.Show(Format('w{} h{}', gw, gh))

#Include aBonsai\bonsai.ahk

config.live := 1
config.timeStep := 40
config.seed := 83
config.leaves := ['#', '&', '*']
main(normal, config)


; hide some text controls ..
elLines.foreach(v => v.foreach(y => y.Visible := (y.Text != '')))

OnMessage(0x0201, (*) => PostMessage(0xA1, 2))