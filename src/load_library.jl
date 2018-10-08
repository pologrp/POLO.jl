function __init__()
    global polo_lib = Libdl.dlopen(joinpath(dirname(@__FILE__), "../", "install", "lib", "libapi.so"));

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
    # ParamserverOptions
    global paramserver_options = Libdl.dlsym(polo_lib, :paramserver_options)
    global delete_paramserver_options = Libdl.dlsym(polo_lib, :delete_paramserver_options)
    global linger = Libdl.dlsym(polo_lib, :linger)
    global master_timeout = Libdl.dlsym(polo_lib, :master_timeout)
    global worker_timeout = Libdl.dlsym(polo_lib, :worker_timeout)
    global scheduler_timeout = Libdl.dlsym(polo_lib, :scheduler_timeout)
    global num_masters = Libdl.dlsym(polo_lib, :num_masters)
    global scheduler = Libdl.dlsym(polo_lib, :scheduler)
    global master = Libdl.dlsym(polo_lib, :master)
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
