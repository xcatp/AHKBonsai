styles := {
  grey: { bg: bk, fg: 'b6b6b6', ex: '' },
  green: { bg: bk, fg: '00ff80', ex: '' },
  orange: { bg: bk, fg: 'ff6f00', ex: '' },
  trunk1: { bg: bk, fg: '7a6b63', ex: '' },
  trunk2: { bg: bk, fg: '8a966c', ex: '' },
  shoot1:  { bg: bk, fg: '704C55', ex: '' },
  shoot2:  { bg: bk, fg: '995e6d', ex: '' },
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
  global
  for v in str {
    win.setCell(x, y,
      CellData(curStyle.fg, curStyle.bg, v, false, curStyle.ex)
    )
    x++
  }
  cx := x, cy := y
}

printMsg(win, str) {
  attron(styles.orange)
  mvprint(win, 0, 0, str)
}
