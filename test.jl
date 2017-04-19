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

q = 0.0;
BCtype = "DNNN";

include("mkl_2d_helmholtz_solver.jl")

# INIT CALL
(ipar, dpar)            = d_init_helmholtz_2d(ax,bx,ay,by,Int32(nx),Int32(ny),BCtype,q);
# create vector for right hand side
f                       = Array{Cdouble}(Int32((ipar[13]+1)*(ipar[14]+1)));
f[:]                    = 0.0;
# COMMIT CALL
(ipar,dpar,f,xhandle)   = d_commit_helmholtz_2d(f,bd_ax,bd_bx,bd_ay,bd_by,ipar,dpar);

# run the garbace collector, this creates a crash right now
gc()

# SOLVE CALL
# ...
# FREE CALL
# ...
