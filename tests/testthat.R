library(SpectraStash)
library(Spectra)
library(testthat)
library(MsDataHub)
library(alabaster.base)

pest_files <- c(PestMix1_DDA.mzML(), PestMix1_SWATH.mzML())
be_mzr <- backendInitialize(MsBackendMzR(), pest_files)

be_hdf5 <- backendInitialize(MsBackendHdf5Peaks(),
                             data = spectraData(filterRt(be_mzr, c(200, 400))),
                             hdf5path = tempdir())

qc_files <- c(MsDataHub::X20171016_POOL_POS_1_105.134.mzML(),
              MsDataHub::X20171016_POOL_POS_3_105.134.mzML())


test_check("SpectraStash")
