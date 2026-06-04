test_that("saveMsObject/readMsObject,MsBackendHdf5Peaks,PlainTextParam works", {
    d <- file.path(tempdir(), "text_h5")

    p <- PlainTextParam(d)
    expect_no_error(saveMsObject(be_hdf5, p))
    expect_equal(dir(d), "ms_backend_spectra_data.txt")
    res <- readMsObject(MsBackendHdf5Peaks(), p)
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_equal(rtime(be_hdf5), rtime(res))
    expect_equal(mz(be_hdf5), mz(res))

    expect_error(saveMsObject(be_hdf5, p), "object stash")
    unlink(d, recursive = TRUE)

    expect_no_error(saveMsObject(be_hdf5, p, consolidate = TRUE))
    expect_true(
        all(c("ms_backend_spectra_data.txt",
              unique(basename(dataStorage(be_hdf5)))) %in% dir(d)))
    res <- readMsObject(MsBackendHdf5Peaks(), p)
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_equal(rtime(be_hdf5), rtime(res))
    expect_equal(mz(be_hdf5), mz(res))
    expect_true(normalizePath(dataStorageBasePath(be_hdf5)) !=
                normalizePath(dataStorageBasePath(res)))

    unlink(d, recursive = TRUE)
})

test_that("alabaster functionality works for MsBackenHdf5Peaks", {
    d <- file.path(tempdir(), "test_hdf5")

    expect_no_error(saveObject(be_hdf5, d))
    expect_true(all(c("OBJECT", "spectra_data", "mod_count") %in% dir(d)))

    expect_no_error(validateMsBackendHdf5Peaks(d))
    res <- readMsBackendHdf5Peaks(d)
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_equal(res, dropNaSpectraVariables(be_hdf5))

    saveObjectFile(d, "other_whatever")
    expect_error(validateMsBackendHdf5Peaks(d), "Invalid OBJECT")
    unlink(d, recursive = TRUE)

    ## consolidate = TRUE
    expect_no_error(saveObject(be_hdf5, d, consolidate = TRUE))
    expect_true(all(c("OBJECT", "spectra_data", "mod_count",
                      basename(unique(dataStorage(be_hdf5)))) %in% dir(d)))
    res <- readMsBackendHdf5Peaks(d)
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_true(normalizePath(dataStorageBasePath(res)) !=
                normalizePath(dataStorageBasePath(be_hdf5)))
    ## unlink(d, recursive = TRUE)

    ## Removing the h5 files in `d`
    fls <- dir(d, pattern = "h5$", full.names = TRUE)
    unlink(fls)

    expect_error(res <- readMsBackendHdf5Peaks(d),
                 "invalid class")
    res <- readMsBackendHdf5Peaks(
        d, spectraPath = dataStorageBasePath(be_hdf5))
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_true(validObject(res))

    unlink(d, recursive = TRUE)

    ## AlabasterParam
    p <- AlabasterParam(d)
    expect_no_error(saveMsObject(be_hdf5, p))
    res <- readMsObject(MsBackendHdf5Peaks(), p)
    expect_equal(res, dropNaSpectraVariables(be_hdf5))

    expect_error(saveMsObject(be_hdf5, p),
                 "cannot save MsBackendHdf5Peaks at existing")
    unlink(d, recursive = TRUE)

    ## AlabasterParam
    p <- AlabasterParam(d)
    expect_no_error(saveMsObject(be_hdf5, p, consolidate = TRUE))
    expect_true(all(c("OBJECT", "spectra_data", "mod_count",
                      basename(unique(dataStorage(be_hdf5)))) %in% dir(d)))

    res <- readMsObject(MsBackendHdf5Peaks(), p)
    expect_equal(normalizePath(dataStorageBasePath(res)), normalizePath(d))
    unlink(d, recursive = TRUE)
})
