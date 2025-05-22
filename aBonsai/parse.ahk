#Include ../_lib/Extend.ahk

Parse(cmd) {
  ec := '\', qc := "'", cs := cmd.toCharArray()
  args := [], p := [], kp := {}, _s := '', i := 1, _q := false
  while i <= cs.Length {
    esc := false
    if cs[i] = ec
      esc := !esc, i++
    if i > cs.Length
      return _fail(Format('转义符后应接任意字符({})', i), 2)
    if !esc and cs[i] = qc
      _q := !_q
    else if cs[i] = A_Space && !_q {
      _push(_s), _s := ''
    } else _s .= cs[i]
    if i = cs.Length and _q
      return _fail(Format('未正确闭合引号({})', i), 1)
    i++
  }

  if _s.length > 0
    _push(_s)
  return _succ(Parsed(p, kp, args, cmd))

  _push(s) {
    if s = ''
      return
    if s[1] != '-' {
      args.push(s)
      return
    }
    if s.Length = 1
      return
    if _ := InStr(s, '=') {
      if kp[k := s.substring(2, _)] { ; 重复键时转化为数组
        kp[k] := Array(kp[k], s.substring(_ + 1))
      } else kp[k] := s.substring(_ + 1)
    } else p.Push(_s.substring(2).toCharArray()*)
  }
  _succ(o) => { valid: true, parsed: o }
  _fail(msg, code) => { valid: false, msg: msg, code: code }
}

class Parsed {

  __New(params, kvparams, extra, raw) {
    this.params := params
    this.kvparams := kvparams
    this.extra := extra
    this.raw := raw
  }

  hasParam(_p) {
    return this.params.findIndex(v => v = _p)
  }

  hasParams(_p*) {
    return _p.every(v => this.hasParam(v))
  }

  getKV(k, default) => this.kvparams[k] || default

}