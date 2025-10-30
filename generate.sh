#!/bin/bash

# PDF Generator for tldraw documentation
# Usage: ./generate.sh [options]

# Default values
GENERATE_MAIN=false
GENERATE_DEEP_DIVE=false
CUSTOM_FILE=""

# Show help
show_help() {
  echo "PDF Generator for tldraw documentation"
  echo ""
  echo "Usage: ./generate.sh [options]"
  echo ""
  echo "Options:"
  echo "  -m, --main              Generate PDF from tldraw.md"
  echo "  -d, --deep-dive         Generate PDF from tldraw-architecture-deep-dive.md"
  echo "  -a, --all               Generate PDFs from both markdown files"
  echo "  -f, --file <filename>   Generate PDF from custom markdown file in docs/"
  echo "  -h, --help              Show this help message"
  echo ""
  echo "Examples:"
  echo "  ./generate.sh -m                    # Generate tldraw.pdf only"
  echo "  ./generate.sh -d                    # Generate deep-dive PDF only"
  echo "  ./generate.sh -a                    # Generate both PDFs"
  echo "  ./generate.sh -f custom.md          # Generate from docs/custom.md"
  echo "  ./generate.sh                       # No args = generate both (default)"
  exit 0
}

# Parse command line arguments
if [ $# -eq 0 ]; then
  # No arguments = generate both
  GENERATE_MAIN=true
  GENERATE_DEEP_DIVE=true
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    -m|--main)
      GENERATE_MAIN=true
      shift
      ;;
    -d|--deep-dive)
      GENERATE_DEEP_DIVE=true
      shift
      ;;
    -a|--all)
      GENERATE_MAIN=true
      GENERATE_DEEP_DIVE=true
      shift
      ;;
    -f|--file)
      CUSTOM_FILE="$2"
      shift 2
      ;;
    -h|--help)
      show_help
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use -h or --help for usage information"
      exit 1
      ;;
  esac
done

# Function to generate PDF
generate_pdf() {
  local input_file=$1
  local input_path="docs/$input_file"
  local output_file="${input_file%.md}.pdf"
  local output_path="docs/$output_file"
  
  if [ ! -f "$input_path" ]; then
    echo "Error: Input file '$input_path' not found"
    return 1
  fi
  
  echo "Generating PDF from $input_file..."
  
  pandoc "$input_path" \
    --pdf-engine=xelatex \
    --toc \
    --toc-depth=3 \
    --number-sections \
    --highlight-style=tango \
    --variable geometry:margin=1in \
    --variable fontsize=11pt \
    --variable mainfont="DejaVu Serif" \
    --variable monofont="DejaVu Sans Mono" \
    --variable colorlinks=true \
    --variable linkcolor=blue \
    --variable urlcolor=blue \
    --variable classoption=openany \
    --include-in-header=<(cat <<'EOF'
\usepackage{tocloft}
\setlength{\cftsecnumwidth}{3em}
\setlength{\cftsubsecnumwidth}{4em}
\setlength{\cftsubsubsecnumwidth}{5em}
EOF
) \
    -o "$output_path"
  
  if [ $? -eq 0 ]; then
    echo "PDF generated: $output_path"
    ls -lh "$output_path"
    echo ""
  else
    echo "Error generating PDF from $input_path"
    return 1
  fi
}

# Generate PDFs based on options
if [ -n "$CUSTOM_FILE" ]; then
  generate_pdf "$CUSTOM_FILE"
fi

if [ "$GENERATE_MAIN" = true ]; then
  generate_pdf "tldraw.md"
fi

if [ "$GENERATE_DEEP_DIVE" = true ]; then
  generate_pdf "tldraw-architecture-deep-dive.md"
fi

echo "Done!"
