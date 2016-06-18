@echo off
cd %~dp0
chcp 1251
if (%1)==() (
	echo Select folder.
	goto end
)
setlocal enabledelayedexpansion
COLOR 0A
mode con:cols=128 lines=50
set pt=%~N1%~X1
cd %pt%
%~dp0bin\chmod og=xr rmdisk
cd rmdisk
echo - pack rmdisk to cpio...
%~dp0bin\find . | %~dp0bin\cpio.exe -o -H newc -F ../new_ram_disk >nul
move ..\ram_disk ..\ram_disk_old >nul
echo - pack rmdisk.cpio to gzip...
%~dp0bin\gzip -f ../new_ram_disk

rem set BASE="0x$(od -A n -h -j 34 -N 2 ./boot.img|sed 's/ //g')0000"
rem set CMDLINE="$(od -A n --strings -j 64 -N 512 ./boot.img)"
echo - make new image...
FOR /F  %%i IN (../pagesize.txt) DO (set ps=%%i)
echo - pagesize %ps%
%~dp0bin\mkbootimg.exe --pagesize %ps% --kernel ../kernel --ramdisk ../new_ram_disk.gz -o ../new_image.img 
copy ..\new_image.img %~dp0\new_image.img
move ..\ram_disk_old ..\ram_disk >nul
cd ..
cd ..
echo - done.
exit
:end

