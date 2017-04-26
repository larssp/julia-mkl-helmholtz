# MKL uses the integer type "MKL_INT", which can either be Int32 or Int64. Choose the appropriate here
MKL_INT = Int32;

# the commit routine returns an opaque pointer "xhandle" of type "DFTI_DESCRIPTOR_HANDLE".
# create a type definition for the type declaration in the ccall

# this does not work
#type DFTI_DESCRIPTOR_HANDLE
#end

# but this does, according to http://bit.ly/2ouOx0J
const DFTI_DESCRIPTOR_HANDLE = Int64
#const DFTI_DESCRIPTOR_HANDLE = Int32

function d_init_helmholtz_2d(ax::Float64, 
                             bx::Float64,
                             ay::Float64,
                             by::Float64,
                             nx::MKL_INT,
                             ny::MKL_INT,
                             BCtype::String,
                             q::Float64)
    
    # convert from type "String" to a UInt8 Array
    in_BCtype    = Array{UInt8}(4);
    in_BCtype[1] = UInt8(BCtype[1]);
    in_BCtype[2] = UInt8(BCtype[2]);
    in_BCtype[3] = UInt8(BCtype[3]);
    in_BCtype[4] = UInt8(BCtype[4]);
    
    # stat is a variable, which value is changed by the fortran routine.
    # therefore, initialize it as a reference, as described in the julia docs:
    # http://bit.ly/2os7VpX
    stat         = Ref{MKL_INT}(0);
    
    # init integer array "ipar" and float array "dpar", which are used by 
    # subsequent routines and therefor returned by this function.
    ipar         = Array{MKL_INT}(128);
    ipar[:]      = 0;
    dpar         = Array{Float64}(Int32(5*nx/2+7));
    dpar[:]      = 0.0;
    
    # Everything is passed by reference, because otherwise it throws
    # invalid memory access exceptions or returns wrong results. 
    # The shared library seems to be written in fortran and not C.
    ccall((:D_INIT_HELMHOLTZ_2D, "mkl_rt"),  # function and library
        Ptr{Void},      # ReturnType Void --> no return value
        (Ref{Float64},  #ax
        Ref{Float64},   #bx
        Ref{Float64},   #ay      
        Ref{Float64},   #by      
        Ref{MKL_INT},   #nx      
        Ref{MKL_INT},   #ny      
        Ref{UInt8},     #BCtype
        Ref{Float64},   #q       
        Ref{MKL_INT},   #ipar
        Ref{Float64},   #dpar
        Ref{MKL_INT},   #stat
        ),
        ax,
        bx,
        ay,
        by,
        nx,
        ny,
        in_BCtype,
        q,
        ipar,
        dpar,
        stat,
        );

    # error handling of the returned status variable "stat"
    if stat[] != 0
        if stat[] == -99999
            error("INIT HELMHOLTZ 2D ERROR: The routine failed to complete the task because of a fatal error.");
        else
            error("INIT HELMHOLTZ 2D ERROR: Unknown error. stat=$(stat[]).");
        end
    end

    return (ipar, dpar)
end



function d_commit_helmholtz_2d(f::Array{Cdouble},
                               bd_ax::Array{Float64},
                               bd_bx::Array{Float64},
                               bd_ay::Array{Float64},
                               bd_by::Array{Float64},
                               ipar::Array{MKL_INT},
                               dpar::Array{Float64})

    stat       = Ref{MKL_INT}(0);
    rxhandle    = Ref{DFTI_DESCRIPTOR_HANDLE}(0);
    
    ccall((:D_COMMIT_HELMHOLTZ_2D, "mkl_rt"),
        Ptr{Void},                      # ReturnType Void --> no return value
        (Ref{Cdouble},                  #f
        Ref{Float64},                   #bd_ax
        Ref{Float64},                   #bd_bx
        Ref{Float64},                   #bd_ay
        Ref{Float64},                   #bd_by
        Ref{DFTI_DESCRIPTOR_HANDLE},    #xhandle    # unknown pointer to a dynamically allocated address
        Ref{MKL_INT},                   #ipar
        Ref{Float64},                   #dpar
        Ref{MKL_INT},                   #stat
        ),
        f,
        bd_ax,
        bd_bx,
        bd_ay,
        bd_by,
        rxhandle,
        ipar,
        dpar,
        stat,
        );
    
    if stat[] != 0
        if stat[] == 1
            warning("COMMIT HELMHOLTZ 2D WARNING: Some warnings exist. See stdout.");
        elseif stat[] == -100
            error("COMMIT HELMHOLTZ 2D ERROR: The routine stopped because an error in the input data was found or the data in the dpar, spar, or ipar array was altered by mistake.");
        elseif stat[] == -1000
            error("COMMIT HELMHOLTZ 2D ERROR: The routine stopped because of the Intel MKL FFT or TT interface error.");
        elseif stat[] == -10000
            error("COMMIT HELMHOLTZ 2D ERROR: The routine stopped because the initialization failed to complete or the parameter ipar[0] was altered by mistake.");
        elseif stat[] == -99999
            error("COMMIT HELMHOLTZ 2D ERROR: The routine failed to complete the task because of a fatal error.");
        else
            error("COMMIT HELMHOLTZ 2D ERROR: Unknown error. stat=$(stat[]).");
        end
    end

    xhandle = rxhandle[];
    return (ipar,dpar,f,xhandle);
end


function d_helmholtz_2d(f::Array{Cdouble},
                        bd_ax::Array{Float64},
                        bd_bx::Array{Float64},
                        bd_ay::Array{Float64},
                        bd_by::Array{Float64},
                        xhandle::DFTI_DESCRIPTOR_HANDLE,
                        ipar::Array{MKL_INT},
                        dpar::Array{Float64})
    
    stat = Ref{MKL_INT}(0);
    
    ccall((:D_HELMHOLTZ_2D, "mkl_rt"),
        Ptr{Void},                      # ReturnType Void --> no return value
        (Ref{Cdouble},                  #f
        Ref{Float64},                   #bd_ax
        Ref{Float64},                   #bd_bx
        Ref{Float64},                   #bd_ay
        Ref{Float64},                   #bd_by
        Ref{DFTI_DESCRIPTOR_HANDLE},    #xhandle
        Ref{MKL_INT},                   #ipar
        Ref{Float64},                   #dpar
        Ref{MKL_INT},                   #stat
        ),
        f,
        bd_ax,
        bd_bx,
        bd_ay,
        bd_by,
        xhandle,
        ipar,
        dpar,
        stat,
        );
    
    if stat[] != 0
        if stat[] == 1
            warning("SOLVE HELMHOLTZ 2D WARNING: Some warnings exist. See stdout.");
        elseif stat[] == -2
            error("SOLVE HELMHOLTZ 2D ERROR: The routine stopped because division by zero occurred. It usually happens if the data in the dpar or spar array was altered by mistake.");
        elseif stat[] == -3
            error("SOLVE HELMHOLTZ 2D ERROR: The routine stopped because the sufficient memory was unavailable for the computations.");
        elseif stat[] == -100
            error("SOLVE HELMHOLTZ 2D ERROR: The routine stopped because an error in the input data was found or the data in the dpar, spar, or ipar array was altered by mistake.");
        elseif stat[] == -1000
            error("SOLVE HELMHOLTZ 2D ERROR: The routine stopped because of the Intel MKL FFT or TT interface error.");
        elseif stat[] == -10000
            error("SOLVE HELMHOLTZ 2D ERROR: The routine stopped because the initialization failed to complete or the parameter ipar[0] was altered by mistake.");
        elseif stat[] == -99999
            error("SOLVE HELMHOLTZ 2D ERROR: The routine failed to complete the task because of a fatal error.");
        else
            error("SOLVE HELMHOLTZ 2D ERROR: Unknown error. stat=$(stat[]).");
        end
    end

    return (ipar,f,xhandle);
end

function free_helmholtz_2d(xhandle::DFTI_DESCRIPTOR_HANDLE,ipar::Array{MKL_INT})
    
    stat = Ref{MKL_INT}(0);
    
    ccall((:FREE_HELMHOLTZ_2D, "mkl_rt"),
        Ptr{Void},                      # ReturnType Void --> no return value
        (Ref{DFTI_DESCRIPTOR_HANDLE},   #xhandle
        Ref{MKL_INT},                   #ipar
        Ref{MKL_INT},                   #stat
        ),
        xhandle,
        ipar,
        stat,
        );
    
    if stat[] != 0
        if stat[] == -1000
            error("FREE HELMHOLTZ 2D ERROR: The routine stopped because of an Intel MKL FFT or TT interface error.");
        elseif stat[] == -99999
            error("FREE HELMHOLTZ 2D ERROR: The routine failed to complete the task because of a fatal error.");
        else
            error("FREE HELMHOLTZ 2D ERROR: Unknown error. stat=$(stat[]).");
        end
    end
end
