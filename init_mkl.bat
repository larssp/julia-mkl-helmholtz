REM initialize Intel MKL variables
REM adding run(`mklvars.bat intel64 lp64`) to the julia script does not work
@echo off
mklvars.bat intel64 lp64
exit 0
