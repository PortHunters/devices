@echo off
chcp 1251 >nul

echo custom.bat by Victor Malyshev (@I1PABIJJA) i1pabijja@gmail.com

set CD=%~dp0
for /d %%I in ("*.zip.bzprj") do (set Project=%%~I)
set Rom=%CD%\%Project%\baseROM\
set Tools=%CD%\i1-tools\
set Repo=%CD%\repositories\

rem standart Args: -pdir %Repo%\patches\main\other\ -uarg:boot %Tools%\boot-tools\ -uarg:repo %Repo% -uarg:rom %Rom%

java -jar %Tools%\i1atcher.jar -pdir %Repo%\patches\main\other\ -uarg:boot %Tools%\boot-tools\ -uarg:repo %Repo% -uarg:rom %Rom%
