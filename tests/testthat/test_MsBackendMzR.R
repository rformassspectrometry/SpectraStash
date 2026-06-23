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

    unlink(d, recursive = TRUE)

    ## consolidate
    expect_no_error(saveMsObject(be_mzr, p, consolidate = TRUE))
    expect_true(all(c("ms_backend_spectra_data.txt",
                      basename(unique(dataStorage(be_mzr)))) %in% dir(d)))
    res <- readMsObject(MsBackendMzR(), p)
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(normalizePath(dataStorageBasePath(res)), normalizePath(d))
    unlink(d, recursive = TRUE)
})

test_that("alabaster functionality works for MsBackendMzR", {
    d <- file.path(tempdir(), "test_alabaster")

    expect_no_error(saveObject(be_mzr, d))
    expect_true(all(c("OBJECT", "spectra_data") %in% dir(d)))

    expect_no_error(validateMsBackendMzR(d))
    res <- readMsBackendMzR(d)
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(res, dropNaSpectraVariables(be_mzr))

    saveObjectFile(d, "other_whatever")
    expect_error(validateMsBackendMzR(d), "Invalid OBJECT")
    unlink(d, recursive = TRUE)

    ## Moving data files & providing spectraPath
    mzml_path <- file.path(tempdir(), "test_mzr")
    dir.create(mzml_path, recursive = TRUE, showWarnings = FALSE)
    new_fls <- file.path(mzml_path, basename(pest_files))
    file.copy(pest_files, new_fls)
    a <- backendInitialize(MsBackendMzR(), new_fls)

    saveObject(a, d)
    res <- readMsBackendMzR(d)
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(res, dropNaSpectraVariables(a))

    unlink(mzml_path, recursive = TRUE)
    expect_no_error(validateMsBackendMzR(d))
    expect_error(readObject(d), "invalid class")
    expect_no_error(
        res <- readMsBackendMzR(d, spectraPath = dataStorageBasePath(be_mzr)))
    expect_s4_class(res, "MsBackendMzR")
    expect_equal(res$rtime, be_mzr$rtime)

    unlink(d, recursive = TRUE)

    ## consolidate
    expect_no_error(saveObject(be_mzr, d, consolidate = TRUE))
    expect_true(all(basename(unique(dataStorage(be_mzr))) %in% dir(d)))
    res <- readObject(d)
    expect_equal(normalizePath(dataStorageBasePath(res)), normalizePath(d))

    unlink(d, recursive = TRUE)

    ## AlabasterParam
    p <- AlabasterParam(d)
    expect_no_error(saveMsObject(be_mzr, p))
    res <- readMsObject(MsBackendMzR(), p)
    expect_equal(res, dropNaSpectraVariables(be_mzr))

    expect_error(saveMsObject(be_mzr, p),
                 "cannot save MsBackendMzR at existing")
    unlink(d, recursive = TRUE)

    ## consolidate
    expect_no_error(saveMsObject(be_mzr, p, consolidate = TRUE))
    expect_true(all(basename(unique(dataStorage(be_mzr))) %in% dir(d)))
    res <- readMsObject(MsBackendMzR(), p)
    expect_equal(normalizePath(dataStorageBasePath(res)), normalizePath(d))

    unlink(d, recursive = TRUE)
})

test_that("saveObject,MsBackendMzR works with different spectra base path", {
    d1 <- file.path(tempdir(), "a")
    d2 <- file.path(tempdir(), "b")
    dir.create(d1)
    dir.create(d2)
    f1 <- file.path(d1, "a.mzML")
    f2 <- file.path(d2, "b.mzML")
    file.copy(qc_files[1], f1)
    file.copy(qc_files[2], f2)
    a <- backendInitialize(MsBackendMzR(), c(f1, f2))
    expect_equal(normalizePath(dataStorageBasePath(a)),
                 normalizePath(tempdir()))

    d <- file.path(tempdir(), "test_mzr")
    saveObject(a, d, consolidate = TRUE)
    expect_true(all(c("a", "b") %in% dir(d)))
    res <- readObject(d)
    expect_true(validObject(res))
    expect_equal(normalizePath(dataStorageBasePath(res)), normalizePath(d))
    expect_equal(res$mz, a$mz)

    ## Move the stash folder.
    fs::dir_copy(d, file.path(tempdir(), "test_mzr2"))
    unlink(d, recursive = TRUE)

    res <- readObject(file.path(tempdir(), "test_mzr2"))
    expect_true(validObject(res))

    unlink(d1, recursive = TRUE)
    unlink(d2, recursive = TRUE)
    unlink(file.path(tempdir(), "test_mzr2"))
})
