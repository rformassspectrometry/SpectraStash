test_that(".check_overwriting works", {
    expect_error(.check_overwriting(tempdir()), "contains already")
    expect_no_error(.check_overwriting(file.path(tempdir(), "a")))
})

test_that(".check_class_comment works", {
    expect_error(.check_class_comment("a", "b", "c"), "Invalid class defined")
    expect_no_error(.check_class_comment("a", "b", "a"))
})

test_that(".check_directory_content works", {
    expect_error(.check_directory_content(tempdir(), "my_file"), "not found")
    file.create(file.path(tempdir(), "my_file"))
    expect_no_error(.check_directory_content(tempdir(), "my_file"))
    unlink(file.path(tempdir(), "my_file"))
})

test_that(".write_spectra_data works", {
    a <- data.frame(a = 1:3, b = "b")
    fl <- file.path(tempdir(), "test.txt")
    expect_no_error(.write_spectra_data(a, file = fl))
    b <- read.table(fl, header = TRUE, sep = "\t")
    rownames(b) <- NULL
    expect_equal(a, b)
    unlink(fl)
})

test_that(".read_spectra_data works", {
    a <- data.frame(a = 1:4, b = "d")
    fl <- file.path(tempdir(), "test.txt")
    write.table(a, file = fl, sep = "\t", row.names = FALSE)
    expect_no_error(b <- .read_spectra_data(fl))
    expect_equal(a, b)
    unlink(fl)
})
