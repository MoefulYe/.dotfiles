WALLPAPER_DIR="$HOME/.config/wallpapers"; files=("$WALLPAPER_DIR"/*); random_file="${files[RANDOM % ${#files[@]}]}"; swww img "$random_file";
