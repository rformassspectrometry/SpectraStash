.onLoad <- function(libname, pkgname) {
    ## MsBackendMzR
    registerValidateObjectFunction("ms_backend_mz_r", validateMsBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readMsBackendMzR)
}
