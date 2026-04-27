library(mzR)

test_that("saveMsObject/readMsObject,MsBackendMzR,PlainTextParam works", {
    d <- file.path(tempdir(), "test_mzr")

    p <- PlainTextParam(d)
    expect_no_error(saveMsObject(be_mzr, p))
    expect_true(file.exists(file.path(d, "ms_backend_spectra_data.txt")))

    res <- readMsObject(MsBackendMzR(), p)
    expect_equal(res, dropNaSpectraVariables(be_mzr))

    expect_error(saveMsObject(be_mzr, p), "contains already an MS")

    unlink(d, recursive = TRUE)

    ## Move the data files
    d <- file.path(tempdir(), "test_mzr")
    dir.create(d, recursive = TRUE)
    new_fls <- file.path(d, basename(pest_files))
    file.copy(pest_files, new_fls)

    a <- backendInitialize(MsBackendMzR(), new_fls)
    expect_no_error(saveMsObject(a, p))
    file.remove(new_fls)
    expect_error(validObject(a), "File(s)", fixed = TRUE)
    expect_error(readMsObject(MsBackendMzR(), p), "File(s)", fixed = TRUE)

    expect_no_error(
        b <- readMsObject(MsBackendMzR(), p,
                          spectraPath = dataStorageBasePath(be_mzr)))
    expect_true(validObject(b))
    expect_equal(b$rtime, be_mzr$rtime)
})
