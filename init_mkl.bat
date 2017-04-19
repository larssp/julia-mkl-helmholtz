REM initialize Intel MKL variables
REM otherwise an error arises: cannot find mkl_intel_thread.dll, even if it is in the PATH
REM adding run(`mklvars.bat intel64 lp64`) to the julia script does not work
@echo off
mklvars.bat intel64 lp64
exit 0
