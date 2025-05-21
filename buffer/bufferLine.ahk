#Include cellData.ahk

class BufferLine {
  line := []

  __New(cols, fillCellData, isWrapped := false) {
    this.line.Length := cols
    cell := fillCellData || CellData('000000', 'FFFFFF', A_Space, false,'')
    loop cols {
      this.setCell(A_Index, cell)
    }
  }

  setCell(idx, cell) {
    this.line[idx] := cell
  }

  getCell(idx) => this.line[idx]

  copyFrom(line) {
    for v in line {
      this.line[A_Index] := v
    }
    return this
  }

  getLineStr(trim, start := 1, end := tW) {
    r := ''
    loop end - start {
      r .= this.line[start + A_Index - 1].ch
    }
    return trim ? RTrim(r) : r
  }
}
