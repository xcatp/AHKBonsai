class CellData {

  __New(fg, bg, ch, combine, ex) {
    this.fg := fg ; 字体颜色
    this.bg := bg ; 背景颜色
    this.ch := ch ; 字符
    this.ex := ex ; 扩展属性
    this.combine := combine
  }

  equals(cell) {
    return this.fg = cell.fg
      && this.bg = cell.bg
      && this.ch = cell.ch
      && this.combine = cell.combine
      && this.ex = cell.ex
  }
}
