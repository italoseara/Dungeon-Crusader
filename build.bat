rem Usage: make.bat [path to love.exe's directory]

set lovePath=%1

if not exist src\ (
    echo src\ directory not found
    exit /b 1
)

if exist game.love del game.love

if exist build\ (
    rmdir /s /q build\
)

mkdir build

pushd src
tar.exe -a -c -f ..\game.zip *
popd

ren game.zip game.love

copy /b "%lovepath%\love.exe" + "game.love" "build/Dungeon Crusader.exe"

for %%f in (%lovepath%\*.dll) do (
    copy /b "%%f" "./build/%%~nxf"
)

del game.love

exit /b 0
