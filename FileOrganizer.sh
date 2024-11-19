#!/bin/bash

# ASCII Art Banner
echo -e "\033[35m"
echo "  _____ _ _       ___                        _              "
echo " |  ___(_) | ___ / _ \ _ __ __ _  __ _ _ __ (_)_______ _ __ "
echo " | |_  | | |/ _ \ | | | '__/ _\` |/ _\` | '_ \| |_  / _ \ '__|"
echo " |  _| | | |  __/ |_| | | | (_| | (_| | | | | |/ /  __/ |   "
echo " |_|   |_|_|\___|\___/|_|  \__, |\__,_|_| |_|_/___\___|_|   "
echo "                          |___/   By CYBWithFlourish        "
echo -e "\033[0m"
echo
echo " Welcome to the File Organizer Script! "
echo " ------------------------------------- "
echo

# Function to display a spinner
spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  tput civis  # Hide the cursor
  while kill -0 $pid 2>/dev/null; do
    for i in $(seq 0 3); do
      printf "\r[%c] Organizing files..." "${spinstr:$i:1}"
      sleep $delay
    done
  done
  printf "\r[✔] Organization complete!         \n"  # Clear the spinner
  tput cnorm  # Restore the cursor
}

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

# Log file setup
log_file="file_organizer.log"
echo "$(date): Files organized from $target_directory." >> "$log_file"

# Start the organization process in the background
(
  # Parse user input and create folders
  for entry in $folder_input; do
    # Split folder name and extensions
    folder_name=$(echo "$entry" | cut -d':' -f1)
    extensions=$(echo "$entry" | cut -d':' -f2 | tr ',' ' ')

    moved_any_file=false

    # Check for files with each extension and move them
    for ext in $extensions; do
      if find "$target_directory" -maxdepth 1 -type f -name "*.$ext" | grep -q .; then
        mkdir -p "$folder_name"
        mv "$target_directory"/*."$ext" "$folder_name/" 2>/dev/null
        moved_any_file=true
      fi
    done

    if [[ "$moved_any_file" == true ]]; then
      echo "$folder_name: $(ls "$folder_name" 2>/dev/null)" >> "$log_file"
    else
      echo "No files moved to $folder_name." >> "$log_file"
    fi
  done
) &
spinner $!  # Call the spinner function with the PID of the background process

echo "Check $log_file for details."
