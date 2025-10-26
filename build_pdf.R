#!/usr/bin/env Rscript
# Build PDF of R Errors Book
# Author: Kai Guo

cat("\n")
cat("╔════════════════════════════════════════════════════════════╗\n")
cat("║  Building: Mastering R Through Errors by Kai Guo          ║\n")
cat("║  This will take 15-20 minutes on first build              ║\n")
cat("╚════════════════════════════════════════════════════════════╝\n")
cat("\n")

# Check and install required packages
cat("📦 Checking required packages...\n")
required <- c("bookdown", "rmarkdown", "tinytex")
missing <- required[!required %in% installed.packages()[,"Package"]]

if (length(missing) > 0) {
  cat("Installing missing packages:", paste(missing, collapse=", "), "\n\n")
  install.packages(missing, repos = "https://cloud.r-project.org")
}

# Check TinyTeX
if (!"tinytex" %in% installed.packages()[,"Package"]) {
  cat("❌ TinyTeX not found!\n")
  cat("Please run: tinytex::install_tinytex()\n")
  quit(status = 1)
}

if (!tinytex::is_tinytex()) {
  cat("⚠️  Warning: TinyTeX might not be installed\n")
  cat("If build fails, run: tinytex::install_tinytex()\n\n")
}

# Load libraries
suppressMessages(library(bookdown))

# Start build
cat("\n🚀 Starting PDF build...\n")
cat("⏱️  Expected time: 15-20 minutes\n\n")

start_time <- Sys.time()

# Build the book
tryCatch({
  render_book(
    "index.Rmd", 
    "bookdown::pdf_book",
    quiet = FALSE
  )
  
  end_time <- Sys.time()
  duration <- round(difftime(end_time, start_time, units="mins"), 1)
  
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║  ✅ SUCCESS! PDF build complete                            ║\n")
  cat("╠════════════════════════════════════════════════════════════╣\n")
  cat(sprintf("║  Time taken: %s minutes                               ║\n", format(duration, width=6)))
  cat("║  Output: docs/mastering-r-through-errors.pdf              ║\n")
  cat("║  Size: ~20-25 MB, ~800 pages                              ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  
  # Try to open the PDF
  pdf_path <- "docs/mastering-r-through-errors.pdf"
  if (file.exists(pdf_path)) {
    cat("📄 Opening PDF...\n")
    if (.Platform$OS.type == "unix") {
      if (Sys.info()["sysname"] == "Darwin") {
        system(paste("open", shQuote(pdf_path)))
      } else {
        system(paste("xdg-open", shQuote(pdf_path)))
      }
    } else if (.Platform$OS.type == "windows") {
      shell.exec(pdf_path)
    }
  }
  
}, error = function(e) {
  cat("\n")
  cat("╔════════════════════════════════════════════════════════════╗\n")
  cat("║  ❌ ERROR: PDF build failed                                ║\n")
  cat("╚════════════════════════════════════════════════════════════╝\n")
  cat("\n")
  cat("Error message:\n")
  cat(conditionMessage(e), "\n\n")
  
  cat("Troubleshooting:\n")
  cat("1. Check that TinyTeX is installed: tinytex::is_tinytex()\n")
  cat("2. Try: bookdown::clean_book() then run again\n")
  cat("3. Check .log files in _book/ directory\n")
  cat("4. Try HTML build first: bookdown::render_book('index.Rmd', 'bookdown::gitbook')\n\n")
  
  quit(status = 1)
})
