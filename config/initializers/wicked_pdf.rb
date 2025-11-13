WickedPdf.config = {
  # Relative path to where the wkhtmltopdf executable is
  exe_path: Gem.bin_path('wkhtmltopdf-binary', 'wkhtmltopdf'),

  # Global Options:
  enable_local_file_access: true,
  margin: { top: 10, bottom: 10, left: 10, right: 10 },

  # Timeout and memory limits
  timeout: 30000
}
