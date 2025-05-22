#Include ../_lib/GdipStarter.ahk


renderLines() { ; 从缓冲区 yBase 开始，创建 tH 行
  buf := normal
  hdc := CreateCompatibleDC()
  hbm := CreateDIBSection(gw + 2, gh + 2)
  obm := SelectObject(hdc, hbm)
  Graph := Gdip_GraphicsFromHDC(hdc)
  Gdip_SetSmoothingMode(Graph, 4)

  Font := 'Consolas'
  Gdip_FontFamilyCreate(Font)

  pBrush := Gdip_BrushCreateSolid('0xFF' bk)
  Gdip_FillRoundedRectangle(Graph, pBrush, 0, 0, gw, gh, 0) ; bk
  Gdip_DeleteBrush(pBrush)

  loop tH {
    line := buf.lines[buf.yBase + A_Index].line, y := A_Index - 1
    for v in line {
      pBrush := Gdip_BrushCreateSolid('0xFF' v.bg)
      options := Format('x{} y{} c{} w{} r5 Centre s20 {}', _x := (A_Index - 1) * CW + 1, _y := y * CH + 1, 'FF' v.fg, CW, v.ex)
      Gdip_FillRectangle(Graph, pBrush, _x - 1, _y - 1, CW + 1, CH + 1)
      Gdip_DeleteBrush(pBrush)
      if v.ch != A_Space and v.ch != ''
        Gdip_TextToGraphics(Graph, v.ch, options, Font, CW, CH)
    }
  }

  pPen := Gdip_CreatePen('0xFF' border, 1)
  Gdip_DrawRectangle(Graph, pPen, 0, 0, gw + 1, gh + 1) ; border
  Gdip_DeletePen(pPen)

  g.GetPos(&x, &y)
  UpdateLayeredWindow(g.Hwnd, hdc, x, y, gw + 2, gh + 2)

  SelectObject(hdc, obm)
  DeleteObject(hbm)
  DeleteDC(hdc)
  Gdip_DeleteGraphics(Graph)
}


updateLines() {
  renderLines()
}