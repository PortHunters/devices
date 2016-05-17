@echo off
chcp 1251 >nul

echo custom.bat by Victor Malyshev (@I1PABIJJA) i1pabijja@gmail.com

echo init folders...

set CD=%~dp0
for /d %%I in ("*.zip.bzprj") do (set RD=%%~I)

set ROM=%CD%\%RD%\baseROM
set Tools=%CD%\data\tools
set pht=%CD%\data\tools\ph-tools
set Repo=%CD%\repositories\patches\main\boot

echo clean dirs...

del %Tools%\*.img
rmdir /S /Q %Tools%\boot_PORT

echo Repacking boot.img...

ren %ROM%\boot.img boot_PORT.img

move /Y %ROM%\boot_PORT.img %Tools%\boot_PORT.img

call %Tools%\MTK_unpack.bat boot_PORT.img 

java -jar %pht%\ph-rr.jar %RD%
java -jar %pht%\ph-cr.jar
java -jar %pht%\ph-id.jar
java -jar %pht%\ph-us.jar %ROM%

copy /Y %Repo%\kernel\* %Tools%\boot_PORT\
copy /Y %Repo%\rmdisk\* %Tools%\boot_PORT\rmdisk\

call %Tools%\MTK_pack.bat boot_PORT

move /Y %Tools%\new_image.img %ROM%\boot.img

del %Tools%\*.img
rmdir /S /Q %Tools%\boot_PORT

echo Repacking Boot.img finished...
