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

InitConfig(argv) {
  global
  config.live := argv.hasParam('l')
  config.infinite := argv.hasParam('I')
  config.printTime := argv.hasParam('p')
  config.verbosity := argv.hasParam('v')
  config.baseType := argv.getKV('type', 1)
  config.seed := argv.getKV('seed', 0)
  config.timeStep := argv.getKV('step', 40)
  config.timeWait := argv.getKV('wait', 1000)
  config.leaves := argv.getKV('leaves', '#&*').split('')
  config.multiplier := argv.getKV('factor', 5)
  config.lifeStart := argv.getKV('life', 32)
}