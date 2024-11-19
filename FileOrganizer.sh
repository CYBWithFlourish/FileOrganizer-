#!/bin/bash


spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p $pid > /dev/null; do
    for i in $(seq 0 3); do
      echo -ne "\b${spinstr:$i:1}"
      sleep $delay
    done
  done
  echo -ne "\b"
}

echo -n "FileOrganizer.sh "

# Prompt user for folder names and extensions
echo "Enter folder names and extensions in this format (FolderName:ext1,ext2,...)."
echo "Example: Images:jpg,png Documents:pdf,docx TextFiles:txt"
read -p "Enter your input (leave blank for default): " folder_input

# Default behavior: Create default folders if no input is provided
if [[ -z "$folder_input" ]]; then
  folder_input="Images:jpg,png Documents:pdf,docx TextFiles:txt"
  echo "No input provided. Using default folders: $folder_input"
fi

# Prompt user for directory choice
echo "Do you want to organize files from:"
echo "1. Current directory"
echo "2. Another directory"
read -p "Enter your choice (1 or 2): " dir_choice

if [[ "$dir_choice" == "1" ]]; then
  target_directory=$(pwd)
elif [[ "$dir_choice" == "2" ]]; then
  read -p "Enter the absolute path of the directory: " target_directory
  if [[ ! -d "$target_directory" ]]; then
    echo "Invalid directory. Exiting..."
    exit 1
  fi
else
  echo "Invalid choice. Exiting..."
  exit 1
fi

echo "Organizing files from: $target_directory"

# Parse user input and create folders
for entry in $folder_input; do
  # Split folder name and extensions
  folder_name=$(echo "$entry" | cut -d':' -f1)
  extensions=$(echo "$entry" | cut -d':' -f2 | tr ',' ' ')

  # Create folder in the current directory
  mkdir -p "$folder_name"

  # Move files with the specified extensions into the folder
  for ext in $extensions; do
    if ls "$target_directory"/*."$ext" 1>/dev/null 2>&1; then
      mv "$target_directory"/*."$ext" "$folder_name/" 2>/dev/null
    else
      echo "No files with extension .$ext found in $target_directory."
    fi
  done
done

# Log actions
log_file="file_organizer.log"
echo "$(date): Files organized from $target_directory." > "$log_file"

# Display organized files in the log
for entry in $folder_input; do
  folder_name=$(echo "$entry" | cut -d':' -f1)
  echo "$folder_name: $(ls "$folder_name" 2>/dev/null)" >> "$log_file"
done

echo "Organization complete. Check $log_file for details."

spinner $!

wait
echo "Task Done!!"
