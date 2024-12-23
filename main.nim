import os, strformat, raylib, common, levels

const screenSize: tuple[x, y: int32] = (800, 450)

if paramCount() < 1:
    quit("expected 'zsm <level>'", 1)

# the first item in the params is the executable path, even though it doesn't show when `commandLineParams` nor `paramCount` is called
# it was really annoying when I accidentally read the executable, not the level file
let levelPath = paramStr(1)
if not levelPath.fileExists():
  quit(fmt"file '{levelPath}' does not exist", 1)
  
let
  levelContent = readFile(levelPath)
  level = try:
    loadLevel(levelContent)
  except LevelError as e:
    quit(e.msg, 1)

var
  screenState = Gameplay
  mutableLevel = level
  cellSize: int32 = 30
  levelOffset: tuple[x, y: int32] = (50, 50)
  playerPos: tuple[x, y: int]

proc main =
  initWindow(screenSize.x, screenSize.y, "ZZZ Switch Minigame")
  setTargetFPS(60)

  while not windowShouldClose():
    beginDrawing()
    clearBackground(Black)

    case screenState:
    of Gameplay:
      if isKeyPressed(R):
        mutableLevel = level
        playerPos = level.StartAsPos()
      elif (isKeyPressed(W) or isKeyPressed(Up)) and mutableLevel.canMoveToCell(playerPos, Up):
        playerPos.y -= 1
        mutableLevel.triggerCell(playerPos, screenState)
      elif (isKeyPressed(S) or isKeyPressed(Down)) and mutableLevel.canMoveToCell(playerPos, Down):
        playerPos.y += 1
        mutableLevel.triggerCell(playerPos, screenState)
      elif (isKeyPressed(A) or isKeyPressed(Left)) and mutableLevel.canMoveToCell(playerPos, Left):
        playerPos.x -= 1
        mutableLevel.triggerCell(playerPos, screenState)
      elif (isKeyPressed(D) or isKeyPressed(Right)) and mutableLevel.canMoveToCell(playerPos, Right):
        playerPos.x += 1
        mutableLevel.triggerCell(playerPos, screenState)

      mutableLevel.draw(cellSize, levelOffset, playerPos)
    of Win:
      if isKeyPressed(R):
        mutableLevel = level
        screenState = Gameplay
        playerPos = level.StartAsPos()
      drawText("you won! press Escape to exit, or R to reset", 70, 10, 20, RayWhite)

    endDrawing()
  closeWindow()

main()
