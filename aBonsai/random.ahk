class PseudoRandom {

  __New(seed) {
    this.seed := seed
    this.a := 1664525     ; 乘数
    this.c := 1013904223  ; 增量
    this.m := 2 ** 32     ; 模数（2^32）
  }

  next(min, max) {
    ; 更新种子并计算下一个伪随机数
    this.seed := Mod(this.a * this.seed + this.c, this.m)
    return floor(this.seed / (this.m / (max - min + 1))) + min ; 返回 min 到 max 之间的整数
  }
}
