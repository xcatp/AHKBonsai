#Include constants.ahk
#Include bufferLine.ahk

class BufferLines {
  lines := []
  yBase := 0 ; 视口起始行

  ; __New(col, row) {
  ;   this.col := col, this.row := row
  ; }

  ; getW() => this.col
  ; getH() => this.row

  fillViewportRows(fillAttr) {
    loop tH {
      this.lines.Push(BufferLines.getBlankLine(fillAttr))
    }
  }

  setCell(x, y, cell) {
    this.lines[y + 1].setCell(x + 1, cell)
  }

  getCell(x, y) => this.lines[y + 1].getCell(x + 1)

  static getBlankLine(fillAttr) => BufferLine(tW, fillAttr)

  appendStrLine(str) {
    line := str.toChs().map(v => CellData('', '', v, false, ''))
    bl := BufferLine(tW, '').copyFrom(line)
    this.lines.Push(bl)
  }

  clear() {
    this.lines := []
    this.yBase := 0
  }

  getLineStr(lineIdx, trim, start, end) {
    return this.lines[lineIdx].getLineStr(trim, start, end)
  }


}
