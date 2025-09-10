#!/usr/bin/env bash

# This script generates a PDF from a Markdown file using Pandoc.
# Usage: ./make-pdf.sh input.md output.pdf

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.md output.pdf"
    exit 1
fi

INPUT_FILE=$1
OUTPUT_FILE=$2

# Check if the input file exists
if [ ! -f "$INPUT_FILE" ]; then
    echo "Error: Input file '$INPUT_FILE' not found!"
    exit 1
fi

# Generate the PDF using Pandoc using small margins
pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" --pdf-engine=xelatex -V geometry:margin=1in
