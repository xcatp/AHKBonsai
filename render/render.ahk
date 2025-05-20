elLines := []

renderLines() { ; 从缓冲区 yBase 开始，创建 tH 行
  buf := normal
  loop tH {
    renderLine(buf.lines[buf.yBase + A_Index].line, A_Index - 1)
  }

  renderLine(line, y) {
    elLines.Push([]), i := elLines.Length
    for v in line {
      t := g.AddText(
        Format('0x80 {} y{} {} Background{} c{}'
          , (A_Index = 1 ? 'xs Section' : 'x+0')
          , y * ch, (v.combine ? 'w' cw * 2 : ''), v.bg, v.fg)
        , v.ch
      )
      t.SetFont(v.ex)
      t.cellData := v
      elLines[i].Push(t)
    }
  }
}

updateLines() { ; 更新视口区域
  ; SendMessage(0x000B, 0, 0, , g)
  buf := normal
  loop tH {
    updateLine(A_Index - 1)
  }
  ; SendMessage(0x000B, 1, 0, , g)
  ; DllCall("RedrawWindow", 'ptr', g.Hwnd, 'ptr', 0, 'ptr', 0, 'int', 0x0105)
}

updateLine(y) {
  loop tW {
    updateCell(A_Index - 1, y)
  }
}

updateCell(x, y) {
  buf := normal
  el := elLines[y + 1][x + 1], cell := buf.lines[buf.yBase + y + 1].line[x + 1]
  if cell.equals(el.cellData) {
    return
  }
  el.Opt(Format('Background{} c{}', cell.bg, cell.fg))
  el.Text := cell.ch
  el.SetFont(cell.ex)
  el.cellData := cell
}
