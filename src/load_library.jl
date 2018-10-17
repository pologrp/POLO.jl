macro load_polo_algorithm(algname)
    serial = Symbol(algname,:_s)
    consistent = Symbol(algname,:_mtc)
    inconsistent = Symbol(algname,:_mti)
    master = Symbol(algname,:_psm)
    worker = Symbol(algname,:_psw)
    scheduler = Symbol(algname,:_pss)
    quote
        global $serial = Libdl.dlsym(polo_lib, $(Meta.quot(serial)))
        global $consistent = Libdl.dlsym(polo_lib, $(Meta.quot(consistent)))
        global $inconsistent = Libdl.dlsym(polo_lib, $(Meta.quot(inconsistent)))
        global $master = Libdl.dlsym(polo_lib, $(Meta.quot(master)))
        global $worker = Libdl.dlsym(polo_lib, $(Meta.quot(worker)))
        global $scheduler = Libdl.dlsym(polo_lib, $(Meta.quot(scheduler)))
    end
end

# Load in `deps.jl`, complaining if it does not exist
const depsjl_path = joinpath(dirname(@__FILE__), "..", "deps", "deps.jl")
if !isfile(depsjl_path)
    error("POLO not installed properly, run Pkg.build(\"POLO\"), restart Julia and try again")
end
include(depsjl_path)

function __init__()
    check_deps()

    global polo_lib = Libdl.dlopen(libpolo)

    # POLO solvers
    @load_polo_algorithm(gradient)
    @load_polo_algorithm(momentum)
    @load_polo_algorithm(nesterov)
    @load_polo_algorithm(adagrad)
    @load_polo_algorithm(adadelta)
    @load_polo_algorithm(adam)
    @load_polo_algorithm(nadam)
    # Serial
    global proxgradient_s = Libdl.dlsym(polo_lib, :proxgradient_s)
    global delete_proxgradient_s = Libdl.dlsym(polo_lib, :delete_proxgradient_s)
    global run_serial = Libdl.dlsym(polo_lib, :run_serial)
    global getf_s = Libdl.dlsym(polo_lib, :getf_s)
    global getx_s = Libdl.dlsym(polo_lib, :getx_s)

    # Multithread
    global proxgradient_mt = Libdl.dlsym(polo_lib, :proxgradient_mt)
    global delete_proxgradient_mt = Libdl.dlsym(polo_lib, :delete_proxgradient_mt)
    global run_multithread = Libdl.dlsym(polo_lib, :run_multithread)
    global getf_mt = Libdl.dlsym(polo_lib, :getf_mt)
    global getx_mt = Libdl.dlsym(polo_lib, :getx_mt)

    # Parameter server
    # Master
    global proxgradient_master = Libdl.dlsym(polo_lib, :proxgradient_master)
    global delete_proxgradient_master = Libdl.dlsym(polo_lib, :delete_proxgradient_master)
    global run_master = Libdl.dlsym(polo_lib, :run_master)
    # Scheduler
    global proxgradient_scheduler = Libdl.dlsym(polo_lib, :proxgradient_scheduler)
    global delete_proxgradient_scheduler = Libdl.dlsym(polo_lib, :delete_proxgradient_scheduler)
    global run_scheduler = Libdl.dlsym(polo_lib, :run_scheduler)
    # Worker
    global proxgradient_worker = Libdl.dlsym(polo_lib, :proxgradient_worker)
    global delete_proxgradient_worker = Libdl.dlsym(polo_lib, :delete_proxgradient_worker)
    global run_worker = Libdl.dlsym(polo_lib, :run_worker)
end
