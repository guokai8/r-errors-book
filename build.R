# Build script for Mastering R Through Errors book

# Set working directory to book location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Function to check and install required packages
check_packages <- function() {
  required <- c("bookdown", "rmarkdown", "knitr", "tidyverse", 
                "data.table", "here", "readr", "readxl")
  
  missing <- required[!(required %in% installed.packages()[,"Package"])]
  
  if(length(missing)) {
    message("Installing missing packages: ", paste(missing, collapse = ", "))
    install.packages(missing)
  } else {
    message("All required packages installed ✓")
  }
}

# Function to build book in different formats
build_book <- function(format = "gitbook") {
  
  message("\n========================================")
  message("Building book in ", format, " format...")
  message("========================================\n")
  
  if (format == "gitbook") {
    bookdown::render_book("index.Rmd", "bookdown::gitbook")
  } else if (format == "pdf") {
    bookdown::render_book("index.Rmd", "bookdown::pdf_book")
  } else if (format == "epub") {
    bookdown::render_book("index.Rmd", "bookdown::epub_book")
  } else if (format == "all") {
    bookdown::render_book("index.Rmd", "all")
  } else {
    stop("Unknown format: ", format, 
         "\nUse: 'gitbook', 'pdf', 'epub', or 'all'")
  }
  
  message("\n========================================")
  message("Build complete!")
  message("========================================\n")
}

# Function to preview book (live reload)
preview_book <- function() {
  message("Starting live preview...")
  message("Book will auto-rebuild when you save changes")
  message("Press Ctrl+C to stop\n")
  
  bookdown::serve_book()
}

# Function to clean build artifacts
clean_build <- function() {
  message("Cleaning build artifacts...")
  
  # Remove built files
  if (dir.exists("docs")) unlink("docs", recursive = TRUE)
  if (dir.exists("_book")) unlink("_book", recursive = TRUE)
  if (file.exists("mastering-r-through-errors.rds")) {
    file.remove("mastering-r-through-errors.rds")
  }
  
  # Remove cached files
  knitr_cache <- list.files(pattern = "*_cache$", 
                           full.names = TRUE, 
                           recursive = TRUE)
  if (length(knitr_cache)) unlink(knitr_cache, recursive = TRUE)
  
  # Remove extracted R files
  r_files <- list.files(pattern = "\\.R$", full.names = TRUE)
  r_files <- r_files[!grepl("build\\.R", r_files)]
  if (length(r_files)) file.remove(r_files)
  
  message("Clean complete!")
}

# Function to test a single chapter
test_chapter <- function(chapter_file) {
  message("Testing chapter: ", chapter_file)
  
  # Extract R code
  temp_r <- tempfile(fileext = ".R")
  knitr::purl(chapter_file, output = temp_r, quiet = TRUE)
  
  # Try to run it
  tryCatch({
    source(temp_r)
    message("✓ Chapter runs successfully")
    return(TRUE)
  }, error = function(e) {
    message("✗ Chapter has errors:")
    message(e$message)
    return(FALSE)
  }, finally = {
    unlink(temp_r)
  })
}

# Function to create new chapter from template
create_chapter <- function(number, title, part = "Part Unknown") {
  
  # Format chapter number
  chapter_num <- sprintf("%02d", number)
  
  # Create filename
  filename <- paste0(chapter_num, "-", 
                    gsub(" ", "-", tolower(title)), 
                    ".Rmd")
  
  if (file.exists(filename)) {
    stop("Chapter file already exists: ", filename)
  }
  
  # Read template
  template <- readLines("chapter-template.Rmd")
  
  # Replace placeholders
  template <- gsub("CHAPTER_TITLE", title, template)
  template <- gsub("CHAPTER_NUMBER", chapter_num, template)
  template <- gsub("PART_NAME", part, template)
  
  # Write file
  writeLines(template, filename)
  
  message("Created: ", filename)
  message("Remember to add to _bookdown.yml!")
  
  # Open in RStudio if available
  if (rstudioapi::isAvailable()) {
    rstudioapi::navigateToFile(filename)
  }
}

# Main menu
main_menu <- function() {
  cat("\n")
  cat("========================================\n")
  cat("  Mastering R Through Errors - Build Menu\n")
  cat("========================================\n\n")
  cat("1. Check packages\n")
  cat("2. Build gitbook (HTML)\n")
  cat("3. Build PDF\n")
  cat("4. Build EPUB\n")
  cat("5. Build all formats\n")
  cat("6. Preview book (live)\n")
  cat("7. Clean build\n")
  cat("8. Test chapter\n")
  cat("9. Create new chapter\n")
  cat("0. Exit\n\n")
  
  choice <- readline("Enter choice: ")
  
  switch(choice,
    "1" = check_packages(),
    "2" = build_book("gitbook"),
    "3" = build_book("pdf"),
    "4" = build_book("epub"),
    "5" = build_book("all"),
    "6" = preview_book(),
    "7" = clean_build(),
    "8" = {
      chapter <- readline("Enter chapter filename: ")
      test_chapter(chapter)
    },
    "9" = {
      num <- as.integer(readline("Enter chapter number: "))
      title <- readline("Enter chapter title: ")
      part <- readline("Enter part name: ")
      create_chapter(num, title, part)
    },
    "0" = return(invisible()),
    {
      message("Invalid choice")
    }
  )
  
  readline("\nPress Enter to continue...")
  main_menu()
}

# If running interactively, show menu
if (interactive()) {
  main_menu()
} else {
  # Command line usage
  args <- commandArgs(trailingOnly = TRUE)
  
  if (length(args) == 0) {
    message("Usage: Rscript build.R [command]")
    message("Commands: check, gitbook, pdf, epub, all, preview, clean")
  } else {
    cmd <- args[1]
    
    if (cmd == "check") {
      check_packages()
    } else if (cmd %in% c("gitbook", "pdf", "epub", "all")) {
      check_packages()
      build_book(cmd)
    } else if (cmd == "preview") {
      preview_book()
    } else if (cmd == "clean") {
      clean_build()
    } else {
      stop("Unknown command: ", cmd)
    }
  }
}
