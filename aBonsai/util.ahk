styles := {
  grey: { bg: '', fg: 'b6b6b6', ex: '' },
  green: { bg: '', fg: '00ff80', ex: '' },
  orange: { bg: '', fg: 'ff6f00', ex: '' },
  trunk1: { bg: '', fg: '7a6b63', ex: '' },
  trunk2: { bg: '', fg: '8a966c', ex: '' },
  shoot1: { bg: '', fg: '704C55', ex: '' },
  shoot2: { bg: '', fg: '995e6d', ex: '' },
  dying1: { bg: '', fg: '00ce3e', ex: 'Italic' },
  dying2: { bg: '', fg: '007510', ex: '' },
  dead1: { bg: '', fg: 'c89670', ex: '' },
  dead2: { bg: '', fg: '915c40', ex: 'Bold' },
}


curStyle := CellData('white', '', '', false, '')

attron(style) {
  curStyle.bg := style.bg
  curStyle.fg := style.fg
  curStyle.ex := style.ex
}


cx := 0, cy := 0 ; 逻辑光标
move(y, x) {
  global
  cy := y, cx := x
}

print(win, str) {
  global
  for v in str {
    win.setCell(cx, cy,
      CellData(curStyle.fg, curStyle.bg, v, false, curStyle.ex)
    )
    cx++
  }
}

mvprint(win, y, x, str) {
  move(y, x), print(win, str)
}

printMsg(win, str) {
  attron(styles.orange)
  w := str.Length + 4, h := 5, y := 3, x := (tW - w) // 2, b := '-'.Repeat(w - 2)
  mvprint(win, y, x, '+' b '+')
  mvprint(win, y + 1, x, '| ')
  attron(styles.green)
  mvprint(win, y + 1, x + (w - str.Length) // 2, str)
  attron(styles.orange)
  mvprint(win, y + 1, x + w - 2, ' |')
  mvprint(win, y + 2, x, '+' b '+')
}


resetWin(win) {
  win.Clear()
  win.fillViewportRows(defaultFillAttr)
}

printHelp(win) {
  resetWin(win)
  white := { bg: '', fg: 'f1f1f1', ex: '' }
  attron(white)
  mvprint(win, 0, 1, 'Usage: ABonsai [-l -seed=83]...')
  attron(styles.grey)
  mvprint(win, 2, 1, '  ahkbonsai is a beautifully random bonsai tree generator.')
  attron({ bg: '', fg: '8497bf', ex: 'Italic Underline' })
  mvprint(win, 3, 1, '                        https://github.com/xcatp/AHKBonsai')
  attron(white)
  mvprint(win, 5, 1, 'Options:')

  static helpStr := [
    '  -l        ', 'live mode: show each step of growth',
    '  -I        ', 'infinite mode: keep growing trees, q to quit',
    '  -p        ', 'print the duration since startup',
    '  -v        ', 'increase output verbosity',
    '  -type     ', 'ascii-art plant base to use, -1 is none',
    '  -seed     ', 'seed random number generator',
    '  -life     ', 'life; higher -> more growth (0-200) ',
    '            ', '   [default: 32]',
    '  -step     ', 'in live mode, wait TIME secs between',
    '            ', '   steps of growth [default: 40]',
    '  -wait     ', 'in infinite mode, wait TIME between each tree ',
    '            ', '   generation [default: 1000]',
    '  -leaves   ', 'list of comma-delimited strings randomly',
    '            ', '   chosen for leaves [default: #&*]',
    '  -factor   ', 'branch multiplier; higher -> more branching',
    '            ', '   (0-20) [default: 5]',
  ]
  i := 1
  while i < helpStr.Length {
    attron(styles.orange)
    mvprint(win, A_Index + 5, 1, helpStr[i])
    attron(styles.grey)
    print(win, helpStr[i + 1])
    i += 2
  }
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
  config.multiplier := clamp(argv.getKV('factor', 5), 0, 20)
  config.lifeStart := clamp(argv.getKV('life', 32), 0, 200)
}

clamp(x, minV, maxV) => Min(Max(x, minV), maxV)


TransparentWin(accent_state, hwnd) {
  ;0, 1, 2, 3
  WCA_ACCENT_POLICY := 19, pad := A_PtrSize = 8 ? 4 : 0, gradient_color := "0x01000000"
  ACCENT_POLICY := Buffer(16, 0), WINCOMPATTRDATA := Buffer(4 + pad + A_PtrSize + 4 + pad, 0)

  NumPut("int", (accent_state > 0 && accent_state < 4) ? accent_state : 0, ACCENT_POLICY, 0)
    , NumPut("int", gradient_color, ACCENT_POLICY, 8)
    , NumPut("int", WCA_ACCENT_POLICY, WINCOMPATTRDATA, 0)
    , NumPut("int*", ACCENT_POLICY.ptr, WINCOMPATTRDATA, 4 + pad)
    , NumPut("uint", ACCENT_POLICY.size, WINCOMPATTRDATA, 4 + pad + A_PtrSize)
  DllCall("user32\SetWindowCompositionAttribute", "ptr", hwnd, "ptr", WINCOMPATTRDATA)
}


FrameShadow(HGui) {
  ; makes the captionless window a drop shadow
  ; code borrowed from here: https://www.autohotkey.com/boards/viewtopic.php?t=29117

  DllCall("dwmapi\DwmIsCompositionEnabled", "IntP", &_ISENABLED := 0) ; Get if DWM Manager is Enabled
  if !_ISENABLED ; if DWM is not enabled, Make Basic Shadow
    DllCall("SetClassLong", "UInt", HGui, "Int", -26, "Int", DllCall("GetClassLong", "UInt", HGui, "Int", -26) |
      0x20000)
  else {
    _MARGINS := Buffer(16)
    NumPut("UInt", 1, _MARGINS, 0)
    NumPut("UInt", 1, _MARGINS, 4)
    NumPut("UInt", 1, _MARGINS, 8)
    NumPut("UInt", 1, _MARGINS, 12)
    DllCall("dwmapi\DwmSetWindowAttribute", "Ptr", HGui, "UInt", 2, "Int*", 2, "UInt", 4)
    DllCall("dwmapi\DwmExtendFrameIntoClientArea", "Ptr", HGui, "Ptr", _MARGINS.Ptr)
  }
}