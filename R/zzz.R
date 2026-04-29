.onLoad <- function(libname, pkgname) {
    ## MsBackendMzR
    registerValidateObjectFunction("ms_backend_mz_r", validateMsBackendMzR)
    registerReadObjectFunction("ms_backend_mz_r", readMsBackendMzR)
    ## MsBackendHdf5Peaks
    registerValidateObjectFunction("ms_backend_hdf5_peaks",
                                   validateMsBackendHdf5Peaks)
    registerReadObjectFunction("ms_backend_hdf5_peaks", readMsBackendHdf5Peaks)
}
