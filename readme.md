# ZZZ Switch Minigame

The tile switch minigame from Zenless Zone Zero, written in Nim using [Naylib](<https://github.com/planetis-m/naylib/tree/main>)

## Compilation

1. `git clone https://github.com/voidwyrm-2/zzz-switch-minigame`
2. `cd zzz-switch-minigame`
3. `nimble install naylib`
4. `nim c -d:release -o:zsm main.nim` (or `nim c -d:release -o:zsm.exe main.nim` on Windows)
5. `./zsm path/to/level` (or `.\zsm.exe path/to/level` on Windows)
