@echo off
cd %~dp0
chcp 1251
if (%1)==() (
	echo Select folder
	goto end
)
setlocal enabledelayedexpansion
COLOR 0A
mode con:cols=128 lines=50
set pt=%~N1%~X1
echo %pt%
copy %pt%\ram_header %~N1\new_ram_with_header >nul
cd %pt%
%~dp0bin\chmod og=xr rmdisk
cd rmdisk

echo - pack rmdisk to cpio...
%~dp0bin\find . | %~dp0bin\cpio.exe -o -H newc -F ../new_ram_disk.cpio >nul
move ..\ram_disk ..\ram_disk_old >nul
copy ..\new_ram_disk.cpio ..\ram_disk
echo - pack rmdisk to gzip...
%~dp0bin\gzip -f ../ram_disk
echo - add header...
%~dp0bin\dd if=../ram_disk.gz >> ../new_ram_with_header
FOR %%i IN (../ram_disk.gz) DO ( set /A size=%%~Zi )
echo - new ramdisk %size% byte
%~dp0bin\sfk166 hex %size% -digits=8 >../../size.txt
FOR %%i IN (../../size.txt) DO ( set /A size=%%~Zi )
%~dp0bin\sfk166 split 1 ../../size.txt ../../1 >nul
FOR /F  %%i IN (../../1.part7) DO (set a1=%%i)
FOR /F  %%i IN (../../1.part8) DO (set a2=%%i)

FOR /F  %%i IN (../../1.part5) DO (set a3=%%i)
FOR /F  %%i IN (../../1.part6) DO (set a4=%%i)

FOR /F  %%i IN (../../1.part3) DO (set a5=%%i)
FOR /F  %%i IN (../../1.part4) DO (set a6=%%i)

FOR /F  %%i IN (../../1.part1) DO (set a7=%%i)
FOR /F  %%i IN (../../1.part2) DO (set a8=%%i)
echo %a7%%a8%>size.txt
echo %a5%%a6%>>size.txt
echo %a3%%a4%>>size.txt
echo %a1%%a2%>>size.txt
echo - add new size in header 0x%a1%%a2% 0x%a3%%a4% 0x%a5%%a6% 0x%a7%%a8%
%~dp0bin\sfk166.exe echo %a1%%a2% %a3%%a4% %a5%%a6% %a7%%a8% +hextobin ../../tmp1.dat
%~dp0bin\sfk166.exe partcopy ../../tmp1.dat 0 4 ../new_ram_with_header 4 -yes>nul

rem bin\sfk166 replace -binary /1A/20/ -dir docs -file .txt .info .note

rem %~dp0bin\sfk166.exe partcopy ../../size.txt -fromto 4 8 ../new_ram_with_header -yes
rem bin\sfk166 replace -binary /1A/20/ -dir docs -file .txt .info .note
rem set BASE="0x$(od -A n -h -j 34 -N 2 ./boot.img|sed 's/ //g')0000"
rem set BASE="0x10000000"
rem set CMDLINE="$(od -A n --strings -j 64 -N 512 ./boot.img)"
echo - make image...
%~dp0bin\mkbootimg.exe --kernel ../kernel_main --ramdisk ../new_ram_with_header -o ../new_image.img 
del size.txt >nul
copy ..\new_image.img %~dp0\new_image.img
move ..\ram_disk_old ..\ram_disk >nul
cd ..
cd ..
del size.txt >nul
del tmp1.dat>nul
del 1.part*>nul

echo - Done^!
echo.
if exist "new_image.img" (
	echo - New image saved as new_image.img. Success.
) else (
	echo - New image did not created.     Fail.
)
echo.
:end

