## Utility functions used across backends/implementations.

#' Check if the file `x` already exists and throw an error if that's TRUE
#'
#' @noRd
.check_overwriting <- function(x) {
    if (file.exists(x))
        stop("The provided path contains already an MS object stash. ",
             "Overwriting an existing stash is not supported. Please remove ",
             "the directory defined with parameter 'path' first.",
             call. = FALSE)
}

#' Check the type of class (`expected`) written e.g. to a text file as a comment
#'
#' @noRd
.check_class_comment <- function(x, file, expected) {
    if (x[1L] != expected)
        stop("Invalid class defined in \"", file, "\": found \"", x[1L],
             "\", but it should be \"", expected, "\".", call. = FALSE)
}

#' Helper function to write a `spectraData` `data.frame` to a tab-delimited
#' text file.
#'
#' @noRd
#'
#' @importFrom utils write.table
.write_spectra_data <- function(x, file, sep = "\t", quote = TRUE,
                                row.names = FALSE, ...) {
    suppressWarnings(
        write.table(as.data.frame(x), file = file, sep = sep, quote = quote,
                    row.names = row.names, ...))
}

#' Helper function to read a `spectraData` `data.frame` from a tab-delimited
#' text file.
#'
#' @noRd
#'
#' @importFrom utils read.table
.read_spectra_data <- function(file, sep = "\t", header = TRUE, ...) {
    d <- read.table(file = file, sep = sep, header = header, ...)
    rownames(d) <- NULL
    d
}
