df <- DataFrame(rtime = c(13.3, 13.6, 23.5), msLevel = c(1L, 2L, 1L))
df$mz <- list(c(12.4, 13.5, 155.3),
              c(123.4, 143.2, 231.3, 243.2),
              c(123.3, 142.4, 155.2, 159.1, 164.3))
df$intensity <- list(c(1, 2, 3),
                     c(1, 2, 3, 4),
                     c(1, 2, 3, 4, 5))
mem <- backendInitialize(MsBackendMemory(), data = df)

test_that(".to_hdf5_backend works", {
    res <- .to_hdf5_backend(MsBackendMemory())
    expect_s4_class(res, "MsBackendHdf5Peaks")
    unlink(file.path(tempdir(), "peaks.h5"))

    res <- .to_hdf5_backend(mem, path = tempdir())
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_true(all(normalizePath(res$dataStorage) ==
                    normalizePath(file.path(tempdir(), "peaks.h5"))))
    expect_equal(res$mz, mem$mz)
    expect_equal(res$intensity, mem$intensity)
    expect_equal(res$rtime, mem$rtime)

    ## Errors
    mem$scanIndex <- c(1L, 2L, 2L)
    unlink(file.path(tempdir(), "peaks.h5"))
    expect_warning(res <- .to_hdf5_backend(mem), "unique values")
    expect_equal(res$scanIndex, 1:3)
    unlink(file.path(tempdir(), "peaks.h5"))
    mem@peaksData <- lapply(mem@peaksData, function(z) {
        z <- cbind(z, other = as.numeric(seq_len(nrow(z))))
        z
    })
    expect_error(.to_hdf5_backend(mem), "only peaks variables")
})

test_that("alabaster stash works for MsBackendMemory", {
    d <- file.path(tempdir(), "mem_test")

    expect_no_error(saveObject(mem, d))
    expect_error(saveObject(mem, d), "existing path")
    expect_true(all(c("OBJECT", "backend") %in% dir(d)))
    expect_true(all(c("OBJECT", "mod_count", "peaks.h5", "spectra_data") %in%
                    dir(file.path(d, "backend"))))
    expect_equal(readObjectFile(d)$type, "ms_backend_memory")
    expect_equal(readObjectFile(file.path(d, "backend"))$type,
                 "ms_backend_hdf5_peaks")
    sd <- readObject(file.path(d, "backend", "spectra_data"))
    expect_true(all(sd$dataStorage == ".//peaks.h5"))

    ## Can we load the Hdf5 backend too?
    res <- readObject(file.path(d, "backend"))
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_true(validObject(res))
    expect_equal(normalizePath(dataStorageBasePath(res)),
                 normalizePath(file.path(d, "backend")))
    ## Read the MsBackendMemory
    res <- readObject(d)
    expect_s4_class(res, "MsBackendMemory")
    expect_equal(res@spectraData[, colnames(mem@spectraData)], mem@spectraData)
    expect_equal(res$rtime, mem$rtime)
    expect_equal(res$intensity, mem$intensity)
    expect_equal(res$mz, mem$mz)

    ## Works if we move the folder?
    fs::dir_copy(d, file.path(tempdir(), "mem_test_moved"))
    unlink(d, recursive = TRUE)
    res2 <- readObject(file.path(tempdir(), "mem_test_moved"))
    expect_s4_class(res, "MsBackendMemory")
    expect_equal(res2$rtime, mem$rtime)
    expect_equal(res2$mz, mem$mz)

    unlink(d, recursive = TRUE)

    ## Repeat with parameter classes
    ap <- AlabasterParam(d)
    expect_no_error(saveMsObject(mem, ap))
    res <- readMsObject(MsBackendMemory(), ap)
    expect_equal(res$rtime, mem$rtime)
    expect_s4_class(res, "MsBackendMemory")
    expect_equal(res$mz, mem$mz)

    res <- readMsObject(MsBackendHdf5Peaks(),
                        AlabasterParam(file.path(d, "backend")))
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_equal(res$rtime, mem$rtime)
    expect_equal(res$mz, mem$mz)

    unlink(d, recursive = TRUE)
})

test_that("Text file based format works with MsBackendMemory", {
    d <- file.path(tempdir(), "test_mem")

    p <- PlainTextParam(d)

    ## Empty object
    expect_no_error(saveMsObject(MsBackendMemory(), p))
    res <- readMsObject(MsBackendMemory(), p)
    expect_s4_class(res, "MsBackendMemory")
    unlink(d, recursive = TRUE)

    expect_no_error(saveMsObject(mem, p))
    expect_error(saveMsObject(mem, p), "contains already an MS object")
    expect_true(all(c("backend", "ms_backend_spectra_data.txt") %in% dir(d)))
    res <- readLines(file.path(d, "ms_backend_spectra_data.txt"))
    expect_equal(res[1L], "# MsBackendMemory")

    ## Load the HDF5 backend...
    res <- readMsObject(MsBackendHdf5Peaks(),
                        PlainTextParam(file.path(d, "backend")))
    expect_s4_class(res, "MsBackendHdf5Peaks")
    expect_equal(res$rtime, mem$rtime)
    expect_equal(res$intensity, mem$intensity)

    res <- readMsObject(MsBackendMemory(), p)
    expect_s4_class(res, "MsBackendMemory")
    expect_equal(res$rtime, mem$rtime)
    expect_equal(res$mz, mem$mz)

    unlink(d, recursive = TRUE)
})

test_that("All works with MsBackendDataFrame too", {
    d <- data.frame(msLevel = c(1L, 2L, 1L, 1L),
                    rtime = c(12.1, 12.2, 13.1, 13.4))
    d$mz <- list(
        c(14.4, 155.2, 186.4),
        c(144.3, 231.3, 345.3, 453.1),
        c(111.2, 142.4, 143.1),
        c(143.3, 144.3, 153.3, 532.3, 641.5)
    )
    d$intensity <- list(
        c(323.2, 53.2, 35.5),
        c(43.3, 54.1, 33.1, 53.1),
        c(435.3, 35312.3, 5432.5),
        c(433.5, 55434.2, 43.4, 54362.1, 24435.3)
    )
    a <- backendInitialize(MsBackendDataFrame(), data = d)

    d <- file.path(tempdir(), "test_df")

    expect_no_error(saveMsObject(a, PlainTextParam(d)))
    res <- readMsObject(MsBackendDataFrame(), PlainTextParam(d))
    expect_s4_class(res, "MsBackendDataFrame")
    expect_equal(res$mz, a$mz)
    expect_equal(res$rtime, a$rtime)
    unlink(d, recursive = TRUE)

    expect_no_error(saveMsObject(a, AlabasterParam(d)))
    res <- readMsObject(MsBackendDataFrame(), AlabasterParam(d))
    expect_s4_class(res, "MsBackendDataFrame")
    expect_equal(res$mz, a$mz)
    expect_equal(res$rtime, a$rtime)
    res <- readObject(d)
    expect_s4_class(res, "MsBackendDataFrame")
    expect_equal(res$mz, a$mz)
    expect_equal(res$rtime, a$rtime)
    unlink(d, recursive = TRUE)
})
