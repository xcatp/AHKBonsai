#Include util.ahk
#Include random.ahk

trunk := 1, shootLeft := 2, shootRight := 3, dying := 4, dead := 5

config := {
  live: 1,
  infinite: 1,
  printTree: 0,   ; TODO
  verbosity: 0,   ; TODO
  lifeStart: 32,
  multiplier: 5,
  baseType: 1,
  seed: 0,
  leavesSize: 0,
  save: 0,
  load: 0,    ; TODO
  targetBranchCount: 0,  ; TODO
  ;
  timeWait: 100,
  timeStep: 40,
  ;
  leaves: [],
  saveFile: createDefaultCachePath(),   ; TODO
  loadFile: createDefaultCachePath()    ; TODO
}

stop := 0, running := false, startTime := A_TickCount
counters := { branches: 0, shoots: 0, shootCounter: 0 }

q:: global stop := 1
;========

quit(conf) {
  global
  stop := 0, running := false
}

saveToFile(fName, seed, branchCount) {

}

loadFromFile(conf) {

}

finish(conf, counters) {

}

drawBase(win, baseType) {
  w := 30, h := 4, y := tH - h, x := tW // 2 - w // 2
  move(y, x)
  attron(styles.grey)
  print(win, ':')
  attron(styles.green)
  print(win, '__________')
  attron(styles.orange)
  print(win, './~~~~\.')
  attron(styles.green)
  print(win, '__________')
  attron(styles.grey)
  print(win, ':')
  attron(styles.grey)
  mvprint(win, y + 1, x, ' \                          / ')
  mvprint(win, y + 2, x, '  \________________________/  ')
  mvprint(win, y + 3, x, '  (_)                    (_)  ')
}

drawWins(win, baseType) {
  drawBase(win, baseType)
}

rand() => _random.next(0, 32767)
roll(&dice, _mod) => dice := mod(rand(), _mod)

updateScreen(timeStep) {
  Sleep timeStep
  updateLines()
}

chooseColor(branchType) {
  switch branchType {
    case trunk:
      attron(Mod(rand(), 2) ? styles.trunk1 : styles.trunk2)
    case shootLeft:
    case shootRight:
      attron(Mod(rand(), 2) ? styles.shoot1 : styles.shoot2)
    case dying:
      attron(Mod(rand(), 10) ? styles.dying1 : styles.dying2)
    case dead:
      attron(Mod(rand(), 3) ? styles.dead1 : styles.dead2)
  }
}


setDeltas(branchType, life, age, multiplier, &returnDx, &returnDy) {
  dx := dy := dice := 0

  switch branchType {
    case trunk:
      if age <= 2 or life < 4
        dy := 0, dx := Mod(rand(), 3) - 1
      else if age < multiplier * 3 {
        dy := Mod(age, multiplier * 0.5) ? 0 : -1
        roll(&dice, 10)
        if dice = 0
          dx := -2
        else if (dice <= 3)
          dx := -1
        else if (dice <= 5)
          dx := 0
        else if (dice <= 8)
          dx := 1
        else dx := 2
      } else {
        roll(&dice, 10)
        dy := dice > 2 ? -1 : 0
        dx := Mod(rand(), 3) - 1
      }
    case shootLeft:
      roll(&dice, 10)
      if (dice >= 0 && dice <= 1)
        dy := -1
      else if (dice >= 2 && dice <= 7)
        dy := 0
      else if (dice >= 8 && dice <= 9)
        dy := 1
      roll(&dice, 10)
      if (dice >= 0 && dice <= 1)
        dx := -2
      else if (dice >= 2 && dice <= 5)
        dx := -1
      else if (dice >= 6 && dice <= 8)
        dx := 0
      else if (dice >= 9 && dice <= 9)
        dx := 1
    case shootRight:
      roll(&dice, 10)
      if (dice >= 0 && dice <= 1)
        dy := -1
      else if (dice >= 2 && dice <= 7)
        dy := 0
      else if (dice >= 8 && dice <= 9)
        dy := 1
      roll(&dice, 10)
      if (dice >= 0 && dice <= 1)
        dx := 2
      else if (dice >= 2 && dice <= 5)
        dx := 1
      else if (dice >= 6 && dice <= 8)
        dx := 0
      else if (dice >= 9 && dice <= 9)
        dx := -1
    case dying:
      roll(&dice, 10)
      if (dice >= 0 && dice <= 1)
        dy := -1
      else if (dice >= 2 && dice <= 8)
        dy := 0
      else if (dice >= 9 && dice <= 9)
        dy := 1
      roll(&dice, 15)
      if (dice >= 0 && dice <= 0)
        dx := -3
      else if (dice >= 1 && dice <= 2)
        dx := -2
      else if (dice >= 3 && dice <= 5)
        dx := -1
      else if (dice >= 6 && dice <= 8)
        dx := 0
      else if (dice >= 9 && dice <= 11)
        dx := 1
      else if (dice >= 12 && dice <= 13)
        dx := 2
      else if (dice >= 14 && dice <= 14)
        dx := 3
    case dead:
      roll(&dice, 10)
      if (dice >= 0 && dice <= 2)
        dy := -1
      else if (dice >= 3 && dice <= 6)
        dy := 0
      else if (dice >= 7 && dice <= 9)
        dy := 1
      dx := Mod(rand(), 3) - 1
  }
  returnDx := dx, returnDy := dy
}

chooseString(conf, branchType, life, dx, dy) {

  if life < 4
    branchType := dying
  switch branchType {
    case trunk:
      if dy = 0
        return '/~'
      else if dx < 0
        return '\|'
      else if dx = 0
        return '/|\'
      else if dx > 0
        return '|/'
    case shootLeft:
      if dy > 0
        return '\\'
      else if (dy = 0)
        return "\\_"
      else if (dx < 0)
        return "\\|"
      else if (dx = 0)
        return "/|"
      else if (dx > 0)
        return "/"
    case shootRight:
      if (dy > 0)
        return "/"
      else if (dy == 0)
        return "_/"
      else if (dx < 0)
        return "\\|"
      else if (dx == 0)
        return "/|"
      else if (dx > 0)
        return "/"
    case dying, dead:
      return conf.leaves[Mod(rand(), conf.leavesSize) + 1]
  }
  return '?'
}

branch(win, conf, counters, y, x, branchType, life) {
  global stop
  counters.branches++
  dx := dy := age := 0, shootCooldown := conf.multiplier
  while life > 0 && !stop {
    life--, age := conf.lifeStart - life
    setDeltas(branchType, life, age, conf.multiplier, &dx, &dy)

    maxY := tH
    if dy > 0 and y > (maxY - 2)
      dy--

    if life < 3
      branch(win, conf, counters, y, x, dead, life)
    else if branchType = 0 and life < conf.multiplier + 2
      branch(win, conf, counters, y, x, dying, life)
    else if (branchType = shootLeft or branchType = shootRight) and life < conf.multiplier + 2
      branch(win, conf, counters, y, x, dying, life)
    else if branchType = trunk and ((Mod(rand(), 3) = 0) or (Mod(life, conf.multiplier) = 0)) {
      if Mod(rand(), 8) = 0 and life > 7 {
        shootCooldown := conf.multiplier * 2
        branch(win, conf, counters, y, x, trunk, life + (Mod(rand(), 5) - 2))
      } else if shootCooldown <= 0 {
        shootCooldown := conf.multiplier * 2
        shootLife := life + conf.multiplier
        counters.shoots++, counters.shootCounter++
        if conf.verbosity {
          ; do log
        }
        branch(win, conf, counters, y, x, Mod(counters.shootCounter, 2) + 1, shootLife)
      }
    }
    shootCooldown--
    if conf.verbosity {
      ;do log
    }
    x += dx, y += dy
    chooseColor(branchType)
    str := chooseString(conf, branchType, life, dx, dy)
    ; 越界判断
    if x < 0 or x >= tW or y < 0 or y >= tH
      continue
    ; 不做宽字符处理
    mvprint(win, y, x, str)
    attron(styles.grey)
    mvprint(win, 1, 0, Format("{:.2f}", (A_TickCount - startTime) / 1000))

    if conf.live and !(conf.load && counters.branches < conf.targetBranchCount)
      updateScreen(conf.timeStep)
  }
}

init(win, conf) {
  drawWins(win, conf.baseType)
}

growTree(win, conf, counters) {
  maxY := tH - 4, maxX := tW
  counters.shoots := 0, counters.branches := 0, counters.shootCounter = rand()

  if conf.verbosity > 0 {
    ; do log maxX, maxY
  }

  branch(win, conf, counters, maxY - 1, maxX // 2, trunk, conf.lifeStart)

  ; update
}

createDefaultCachePath() {

}


main(win, conf) {
  global stop, running
  if running {
    return
  }

  global startTime := A_TickCount
  stop := 0, running := true

  resetWin(win)
  if conf.leaves.Length = 0 {
    conf.leaves.Push('&')
  }
  conf.leavesSize := conf.leaves.Length

  if conf.load
    loadFromFile(conf)

  if conf.seed = 0 {
    conf.seed := Random(0, 100000)
  }
  global _random := PseudoRandom(conf.seed)
  attron(styles.orange)
  mvprint(win, 0, 0, 'seed:' conf.seed)

  loop {
    init(win, conf)
    growTree(win, conf, counters)
    if conf.load
      conf.targetBranchCount := 0
    if conf.infinite {
      Sleep conf.timeWait
      mvprint(win, tH - 1, 0, 'Loop' A_Index)
    }
  } until stop or !conf.infinite

  mvprint(normal, 1, 0, 'Done!   ')
  updateScreen(0)

  if conf.printTree {
    finish(conf, counters)
    ; do print
  } else {
    finish(conf, counters)
  }
  quit(conf)
}