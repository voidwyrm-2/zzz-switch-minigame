import strutils, re, strformat, options, raylib, common


type
  LevelError* = object of CatchableError
  CellType* = enum Empty, Inactive, Active, Start, End
  Direction* = enum Up, Down, Left, Right
  Level* = tuple[size, start: tuple[x, y: uint32], cells: seq[seq[CellType]]]

proc draw*(level: Level, cellSize: int32, offset: tuple[x, y: int32], playerPos: tuple[x, y: int]) =
  for j, column in level.cells:
    for i, cell in column:
      let cellColor = case cell:
        of Empty:
          Black
        of Inactive:
          LightGray
        of Active:
          Orange
        of Start:
          Pink
        of End:
          DarkGreen
      drawRectangle(offset.x + (int32(i) * cellSize), offset.y + (int32(j) * cellSize), cellSize, cellSize, if (i, j) == playerPos: DarkBlue else: cellColor)

func canMoveToCell*(level: Level, playerPos: tuple[x, y: int], dir: Direction): bool =
  var isValid: bool

  case dir:
  of Up:
    isValid = if playerPos.y - 1 > -1: level.cells[playerPos.y - 1][playerPos.x] != Empty else: false
  of Down:
    isValid = if playerPos.y + 1 < level.cells.len: level.cells[playerPos.y + 1][playerPos.x] != Empty else: false
  of Left:
    isValid = if playerPos.x - 1 > -1: level.cells[playerPos.y][playerPos.x - 1] != Empty else: false
  of Right:
    isValid = if playerPos.x + 1 < level.cells[playerPos.y].len: level.cells[playerPos.y][playerPos.x + 1] != Empty else: false

  isValid

func hasWon(level: Level): bool =
  for column in level.cells:
    for cell in column:
      if cell == Inactive:
        return false
  true

proc StartAsPos*(level: Level): tuple[x, y: int] = (int(level.start.x), int(level.start.y))

proc triggerCell*(level: var Level, pos: tuple[x, y: int], screenState: var ScreenState) =
  case level.cells[pos.y][pos.x]
  of Empty:
    raiseAssert "unreachable"
  of Inactive:
    level.cells[pos.y][pos.x] = Active
  of Active:
    level.cells[pos.y][pos.x] = Inactive
  of Start:
    discard
  of End:
    if level.hasWon():
      screenState = Win


func loadLevel*(data: string): Level =
  let 
    sizeCheck = re"[0-9]*x[0-9]*"
    lines = data.toLowerAscii().split('\n')
  var
    size: tuple[x, y: uint32]
    start, finish: Option[tuple[x, y: uint32]]
    cells: seq[seq[CellType]]

  if lines[0] =~ sizeCheck:
    let
      xy = lines[0].split('x')
      x = parseUInt(xy[0].strip())
      y = parseUInt(xy[1].strip())
    
    if x < 0 or y < 0:
      raise newException(LevelError, "level dimensions cannot be zero")

    size = (uint32(x), uint32(y))
  else:
    raise newException(LevelError, fmt"invalid level size(expected '[X]x[Y]', got '{lines[0]}')")

  if uint32(lines.len - 1) < size.y:
    raise newException(LevelError, "the actual height of the level is less than the height given")

  for i, row in lines:
    if i == 0:
      continue
    elif uint32(i) > size.y:
      break
    elif uint32(row.len) < size.x:
      raise newException(LevelError, fmt"the actual width of row {i} is less than the width given")
    elif i - 1 >= cells.len:
      cells.add(@[])

    for j, ch in row:
      # echo fmt"column {i}, row {j + 1}: '{ch}'" 
      if uint32(j) >= size.x:
        continue

      case ch
      of ' ':
        cells[i - 1].add(Empty)
      of 'i':
        cells[i - 1].add(Inactive)
      of 'a':
        cells[i - 1].add(Active)
      of 's':
        if start != none(tuple[x, y: uint32]):
          raise newException(LevelError, fmt"redefinition of start cell on column {i}, row {j + 1}")
        start = option((uint32(j), uint32(i - 1)))
        cells[i - 1].add(Start)
      of 'e':
        if finish != none(tuple[x, y: uint32]):
          raise newException(LevelError, fmt"redefinition of end cell on column {i}, row {j + 1}")
        finish = option((uint32(j), uint32(i - 1)))
        cells[i - 1].add(End)
      else:
        raise newException(LevelError, fmt"invalid cell ID '{ch}' on column {i}, row {j + 1}")

  return (size, start.get(), cells)

#[
echo loadLevel("""3x3
sii
iii
iie""")

echo loadLevel("""5x5
siiii
iiiii
iiiii
iiiii
iiiie""")
]#
