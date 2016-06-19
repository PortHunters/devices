@echo off

cd "%~dp0"
IF EXIST "%~dp0\bin" SET PATH=%PATH%;"%~dp0\bin"
Setlocal EnableDelayedExpansion
if (%1)==() (
	echo Select image
		goto end
)

set "file=%~nx1"
set "folder=%~N1"
set "isMTK=%~2"

if exist "%folder%" rd /s/q "%folder%"
md %folder%

if "isMTK" == "" goto nomtk
unpackbootimg -i %file% -o %folder% --mtk 1
goto donecheck
:nomtk
unpackbootimg -i %file% -o %folder%
:donecheck
cd %folder%
for %%a in ("%file%-ramdisk.*") do set ext=%%~xa
type nul > %file%-ramdisk-compress
echo %ext:~1% > "%file%-ramdisk-compress"
md ramdisk
goto %ext:~1%
:gz
cd ramdisk
gzip -dcv "../%file%-ramdisk.gz" | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.gz"
cd ..\
goto end
:lzma
cd ramdisk
xz -dcv "../%file%-ramdisk.lzma" | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.lzma"
cd ..\
goto end
:xz
cd ramdisk
xz -dcv "../%file%-ramdisk.xz" | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.xz"
cd ..\
goto end
:bz2
cd ramdisk
bzip2 -dcv "../%file%-ramdisk.bz2" | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.bz2"
cd ..\
goto end
:lz4
cd ramdisk
lz4 -dv "../%file%-ramdisk.lz4" stdout | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.lz4"
cd ..\
goto end
:lzo
cd ramdisk
lzop -dcv "../%file%-ramdisk.lzo" | cpio -i
if %errorlevel% neq 0 goto ziperror
cd ..\
del "%file%-ramdisk.lzo"
cd ..\
goto end
:ziperror
echo "Your ramdisk archive is corrupt. Are you trying to unpack a MTK image with regular script?"
goto end
:end
exit
