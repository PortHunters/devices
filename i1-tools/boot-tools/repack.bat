@echo off
cd "%~dp0"
IF EXIST "%~dp0\bin" SET PATH=%PATH%;"%~dp0\bin"
Setlocal EnableDelayedExpansion
if (%1)==() (
	echo Select folder
	goto end
)
if "%~n1" == "" goto noinput
set "folder=%~n1"
cd %folder%
echo Repacking the image....
for /f "delims=" %%a in ('dir /b *-kernel') do set nfile=!nfile!%%~na
set "file=%nfile%"
if not exist "%file%.img-kernel" goto error
set kernel=!kernel!%file%.img-kernel
echo Getting the ramdisk compression....
if not exist "ramdisk" goto error
for /f "delims=" %%a in (%file%.img-ramdisk-compress) do set compress=!compress!%%a
goto %compress%
:gz
echo(
mkbootfs ramdisk | minigzip -c -9 > %file%.img-ramdisk.gz
set ramdisk=!ramdisk!%file%.img-ramdisk.gz
echo "The ramdisk is:      %ramdisk%"
goto repack
:xz
mkbootfs ramdisk | xz -1zv -Ccrc32 > %file%.img-ramdisk.xz
set ramdisk=!ramdisk!%file%.img-ramdisk.xz
echo "The ramdisk is:      %ramdisk%"
goto repack
:lzma
mkbootfs ramdisk | xz --format=lzma -1zv > %file%.img-ramdisk.lzma
set ramdisk=!ramdisk!%file%.img-ramdisk.lzma
echo "The ramdisk is:      %ramdisk%"
goto repack
:bz2
mkbootfs ramdisk | bzip2 -kv > %file%.img-ramdisk.bz2
set ramdisk=!ramdisk!%file%.img-ramdisk.bz2
echo "The ramdisk is:      %ramdisk%"
goto repack
:lz4
mkbootfs ramdisk | lz4 -l stdin stdout > %file%.img-ramdisk.lz4
set ramdisk=!ramdisk!%file%.img-ramdisk.lz4
echo "The ramdisk is:      %ramdisk%"
goto repack
:lzo
mkbootfs ramdisk | lzop -v > %file%.img-ramdisk.lzo
set ramdisk=!ramdisk!%file%.img-ramdisk.lzo
echo "The ramdisk is:      %ramdisk%"
goto repack
:repack
echo Getting the image repacking arguments....
if not exist "%file%.img-board" goto noboard
for /f "delims=" %%a in (%file%.img-board) do set nameb=!nameb!%%a
echo "Board:             '%nameb%'"
:noboard
if not exist "%file%.img-base" goto nobase
for /f "delims=" %%a in (%file%.img-base) do set base=!base!%%a
echo "Base:              %base%"
:nobase
for /f "delims=" %%a in (%file%.img-pagesize) do set pagesize=!pagesize!%%a
echo "Pagesize:          %pagesize%"
if not exist "%file%.img-cmdline" goto nocmdline
for /f "delims=" %%a in (%file%.img-cmdline) do set scmdline=!scmdline!%%a
echo "Command line:      '%scmdline%'"
:nocmdline
if not exist "%file%.img-kernel_offset" goto nokoff
for /f "delims=" %%a in (%file%.img-kernel_offset) do set koff=!koff!%%a
echo "Kernel offset:     %koff%"
:nokoff
if not exist "%file%.img-ramdisk_offset" goto noramoff
for /f "delims=" %%a in (%file%.img-ramdisk_offset) do set ramoff=!ramoff!%%a
echo "Ramdisk offset:    %ramoff%"
:noramoff
if not exist "%file%.img-second_offset" goto nosecoff
for /f "delims=" %%a in (%file%.img-second_offset) do set fsecoff=!fsecoff!%%a
echo "Second offset:     %fsecoff%"
set "secoff=--second_offset %fsecoff%"
:nosecoff
if not exist "%file%.img-second" goto nosecd
set fsecd=!fsecd!%file%.img-second
ctext "Second bootloader:{0E} %fsecd%{07}{\n}"
set "second=--second %fsecd%"
echo(
:nosecd
if not exist "%file%.img-tags_offset" goto notagoff
for /f "delims=" %%a in (%file%.img-tags_offset) do set tagoff=!tagoff!%%a
echo "Tags offset:       %tagoff%"
:notagoff
if not exist "%file%.img-dt" goto nodt
set fdt=!fdt!%file%.img-dt
echo "Device tree blob:  %fdt%"
set "dtb=--dt %fdt%"
:nodt
:newimage
set "newimage=new_%folder%"
:command
echo "Your new image is %newimage%.img."
echo Executing the repacking command....
if not exist "%file%.img-mtk" goto notmtk
mkbootimg --kernel %kernel% --ramdisk %ramdisk% --pagesize %pagesize% --base %base% --board "%nameb%" --kernel_offset %koff% --ramdisk_offset %ramoff% --tags_offset %tagoff% %second% --cmdline "%scmdline%" %secoff% %dtb% --mtk 1 -o ..\%newimage%.img
goto endcommand
:notmtk
mkbootimg --kernel %kernel% --ramdisk %ramdisk% --pagesize %pagesize% --base %base% --board "%nameb%" --kernel_offset %koff% --ramdisk_offset %ramoff% --tags_offset %tagoff% %second% --cmdline "%scmdline%" %secoff% %dtb% -o ..\%newimage%.img
:endcommand
del "%file%.img-ramdisk.%compress%"
cd ..\
echo "Done. Your new image was repacked as %newimage%.img"
goto end
:noinput
echo "No folder selected. Exit script."
goto end
:error
echo "There is an error in your folder. The kernel or ramdisk is missing. Exit script."
:end
exit
