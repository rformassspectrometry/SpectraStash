library(StashSpectra)
library(Spectra)
library(testthat)
library(MsDataHub)
library(alabaster.base)

pest_files <- c(PestMix1_DDA.mzML(), PestMix1_SWATH.mzML())
be_mzr <- backendInitialize(MsBackendMzR(), pest_files)

be_hdf5 <- backendInitialize(MsBackendHdf5Peaks(), data = spectraData(be_mzr),
                             hdf5path = tempdir())

test_check("StashSpectra")
