styles := {
  grey: { bg: bk, fg: 'b6b6b6', ex: '' },
  green: { bg: bk, fg: '00ff80', ex: '' },
  orange: { bg: bk, fg: 'ff6f00', ex: '' },
  trunk1: { bg: bk, fg: '7a6b63', ex: '' },
  trunk2: { bg: bk, fg: '8a966c', ex: '' },
  shoot1: { bg: bk, fg: '704C55', ex: '' },
  shoot2: { bg: bk, fg: '995e6d', ex: '' },
  dying1: { bg: bk, fg: '00ce3e', ex: 'italic' },
  dying2: { bg: bk, fg: '007510', ex: '' },
  dead1: { bg: bk, fg: 'c89670', ex: '' },
  dead2: { bg: bk, fg: '915c40', ex: 'bold' },
}


curStyle := CellData('white', bk, '', false, '')

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
  win.fillViewportRows(CellData('b7b7b7', bk, A_Space, false, ''))
}