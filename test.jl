# testcase for the helmholtz solver for the poisson case (q=0)

nx = 100;
ny = 126;

ax = 0.0;
bx = 1.0;
ay = 0.0;
by = 2.5;

bd_ax  = zeros(ny);
bd_bx  = zeros(ny);
bd_ay  = zeros(nx);
bd_by  = zeros(nx);

q      = 0.0;
BCtype = "DNNN";

# create vector for right hand side
f      = Array{Cdouble}(undef,Int32((nx+1)*(ny+1)));
f[:]  .= 0.0;

include("mkl_2d_helmholtz_solver.jl")

# Garbace Collection Safety
# acc. to https://tinyurl.com/y6yzb74a
gcsaver = Array{Ref,1}(undef, 1)

# INIT CALL
(ipar, dpar)            = d_init_helmholtz_2d(ax,bx,ay,by,Int32(nx),Int32(ny),BCtype,q);

# COMMIT CALL
(ipar,dpar,f,xhandle)   = d_commit_helmholtz_2d(f,bd_ax,bd_bx,bd_ay,bd_by,ipar,dpar);
gcsaver[1] = xhandle

# SOLVE CALL
# the content of "f" is replaced by the desired solution
# get ipar and xhandle returned, because the memory is freed
# by a separate function in the shared library
(ipar,f,xhandle)   = d_helmholtz_2d(f,bd_ax,bd_bx,bd_ay,bd_by,xhandle,ipar,dpar);

# FREE CALL
free_helmholtz_2d(xhandle,ipar);

# make the xhandle Reference available to the GC
gcsaver[1] = Ref{Int32}(0)
