library(StashSpectra)
library(Spectra)
library(testthat)
library(MsDataHub)
library(alabaster.base)

pest_files <- c(PestMix1_DDA.mzML(), PestMix1_SWATH.mzML())
be_mzr <- backendInitialize(MsBackendMzR(), pest_files)

test_check("StashSpectra")
