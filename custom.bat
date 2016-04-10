@echo off
chcp 1251 >nul

set CD=%~dp0
pushd "%~dp0"
for /d %%I in ("*.zip.bzprj") do (
    set RD="%%~I"
)
popd
set ROM=%CD%\%RD%\baseROM
set Tools=%CD%\data\tools
set pht=%CD%\data\tools\ph-tools
set Repo=%CD%\repositories\patches\main\boot

del %Tools%\*.img
rmdir /S /Q %Tools%\boot_PORT

ren %ROM%\boot.img boot_PORT.img

move /Y %ROM%\boot_PORT.img %Tools%\boot_PORT.img

call %Tools%\MTK_unpack.bat boot_PORT.img 

java -jar %pht%\ph-cr.jar

copy /Y %Repo%\kernel\* %Tools%\boot_PORT\
copy /Y %Repo%\rmdisk\* %Tools%\boot_PORT\rmdisk\

call %Tools%\MTK_pack.bat boot_PORT

move /Y %Tools%\new_image.img %ROM%\boot.img

del %Tools%\*.img
rmdir /S /Q %Tools%\boot_PORT

echo Repacking Boot.img finished...
