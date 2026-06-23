test_that("test .onLoad", {
    ## collect options before and after loading the package
    ## use different R subprocesses based on loading context
    option_output <- {
        if (!pkgload::is_dev_package() || testthat:::in_covr()) {
            callr::r(function() {
                preOpts <- options()
                library(SpectraStash)
                expect_no_error(SpectraStash:::.onLoad())
                postOpts <- options()
                list(preOpts = preOpts, postOpts = postOpts)
            })
        } else if (pkgload::is_dev_package()) {
            callr::r(function() {
                preOpts <- options()
                pkgload::load_all()
                expect_no_error(SpectraStash:::.onLoad())
                postOpts <- options()
                list(preOpts = preOpts, postOpts = postOpts)
            })
        }
    }
    expect_type(option_output, "list")
})
