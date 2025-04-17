#!/bin/bash

# --- Configuration ---
OBSIDIAN_READY_PATH="/home/kyleh34/Documents/Obsidian_Blog_Files/Blog Posts Archive/Ready to Push/"
HUGO_CONTENT_PATH="./content/posts"
HUGO_STATIC_IMAGES="./static/images/" # Specific subdirectory for post images
HUGO_STATIC_DOCS="./static/docs"         # Subdirectory for documents
HUGO_STATIC_DOWNLOADS="./static/downloads"      # Subdirectory for general downloads
HUGO_STATIC_AUDIO="./static/audio"          # Subdirectory for audio
HUGO_STATIC_VIDEO="./static/video"          # Subdirectory for video
OBSIDIAN_STATIC_ASSETS="/home/kyleh34/Documents/Obsidian_Blog_Files/Blog Posts Archive/Static Assets/" # Root for static assets
OBSIDIAN_IMAGE_PATH="$OBSIDIAN_STATIC_ASSETS/images/" # path to images directory
OBSIDIAN_DOCS_PATH="$OBSIDIAN_STATIC_ASSETS/docs/"   # path to documents directory
OBSIDIAN_DOWNLOADS_PATH="$OBSIDIAN_STATIC_ASSETS/downloads/" # path to general downloads
OBSIDIAN_AUDIO_PATH="$OBSIDIAN_STATIC_ASSETS/audio/"   # path to audio files
OBSIDIAN_VIDEO_PATH="$OBSIDIAN_STATIC_ASSETS/video/"   # path to video files
GIT_REPO_PATH="/home/kyleh34/Documents/Obsidian_Blog_Files/Millennial_Projects" # Explicit path to Git repo
# --- End Configuration ---

# --- Helper Functions ---
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2
}

log_warning() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1"
}

check_directory() {
    if [ ! -d "$1" ]; then
        log_error "Directory not found: $1"
        exit 1
    fi
}

# --- Script Start ---
log_info "Starting blog post publishing process..."

# 1. Check for required directories
check_directory "$OBSIDIAN_READY_PATH"
check_directory "$HUGO_CONTENT_PATH"
check_directory "$HUGO_STATIC_IMAGES"
check_directory "$HUGO_STATIC_DOCS"
check_directory "$HUGO_STATIC_DOWNLOADS"
check_directory "$HUGO_STATIC_AUDIO"
check_directory "$HUGO_STATIC_VIDEO"
check_directory "$OBSIDIAN_IMAGE_PATH"
check_directory "$OBSIDIAN_DOCS_PATH"
check_directory "$OBSIDIAN_DOWNLOADS_PATH"
check_directory "$OBSIDIAN_AUDIO_PATH"
check_directory "$OBSIDIAN_VIDEO_PATH"
check_directory "$GIT_REPO_PATH"

processed_files=() # Array to store processed Obsidian filenames

# 2. Find all Markdown files in the Obsidian Ready to Push folder
log_info "Finding Markdown files in Obsidian archive..."
find "$OBSIDIAN_READY_PATH" -maxdepth 1 -name "*.md" -print0 | while IFS= read -r -d $'\0' obsidian_file; do
    filename=$(basename "$obsidian_file")
    post_slug="${filename%.md}"
    hugo_output_path="$HUGO_CONTENT_PATH/$post_slug.md"

    log_info "Processing file: $filename"

    # Check if a Hugo post with the same slug already exists (optional)
    if [ -f "$hugo_output_path" ]; then
        log_info "Hugo post already exists: $post_slug. Skipping."
        continue
    fi

    # 3. Copy the Markdown file to Hugo content
    log_info "Copying '$obsidian_file' to '$hugo_output_path'"
    if ! cp "$obsidian_file" "$hugo_output_path"; then
        log_error "Failed to copy '$obsidian_file' to '$hugo_output_path'."
        continue
    fi
    processed_files+=("$filename") # Add the processed filename to the array

    # 4. Handle Static Assets (Images, Docs, Downloads, Audio, Video)
    log_info "Handling static assets for '$filename'..."
    grep -oP "!\[.*?\]\(([^)]+)\)" "$hugo_output_path" | while IFS= read -r asset_markdown; do
        asset_path_relative=$(echo "$asset_markdown" | sed -E 's/!\[.*?\]\((.*?)\)/\1/')
        asset_filename=$(basename "$asset_path_relative")
        asset_extension="${asset_filename##*.}"

        case "$asset_extension" in
            jpg|jpeg|png|gif)
                potential_source_path="$OBSIDIAN_IMAGE_PATH/$asset_filename"
                hugo_dest_path="$HUGO_STATIC_IMAGES/$asset_filename"
                hugo_link_path="/images/$asset_filename"
                hugo_dest_dir="$HUGO_STATIC_IMAGES"
                ;;
            pdf|txt)
                potential_source_path="$OBSIDIAN_DOCS_PATH/$asset_filename"
                hugo_dest_path="$HUGO_STATIC_DOCS/$asset_filename"
                hugo_link_path="/docs/$asset_filename"
                hugo_dest_dir="$HUGO_STATIC_DOCS"
                ;;
            sh|zip)
                potential_source_path="$OBSIDIAN_DOWNLOADS_PATH/$asset_filename"
                hugo_dest_path="$HUGO_STATIC_DOWNLOADS/$asset_filename"
                hugo_link_path="/downloads/$asset_filename"
                hugo_dest_dir="$HUGO_STATIC_DOWNLOADS"
                ;;
            mp3)
                potential_source_path="$OBSIDIAN_AUDIO_PATH/$asset_filename"
                hugo_dest_path="$HUGO_STATIC_AUDIO/$asset_filename"
                hugo_link_path="/audio/$asset_filename"
                hugo_dest_dir="$HUGO_STATIC_AUDIO"
                ;;
            mp4)
                potential_source_path="$OBSIDIAN_VIDEO_PATH/$asset_filename"
                hugo_dest_path="$HUGO_STATIC_VIDEO/$asset_filename"
                hugo_link_path="/video/$asset_filename"
                hugo_dest_dir="$HUGO_STATIC_VIDEO"
                ;;
            *)
                log_warning "Unsupported asset type: '$asset_filename'. Skipping."
                continue
                ;;
        esac

        if [ -f "$potential_source_path" ]; then
            log_info "Copying '$asset_filename' to '$hugo_dest_path'"
            mkdir -p "$hugo_dest_dir"
            if ! cp "$potential_source_path" "$hugo_dest_path"; then
                log_warning "Failed to copy '$asset_filename'."
            else
                # Update the link in the Hugo Markdown
                sed -i "s!($asset_path_relative)!($hugo_link_path)!g" "$hugo_output_path"
            fi
        else
            log_warning "Asset '$asset_filename' not found in Obsidian path."
        fi
    done
    log_info "Finished processing assets for '$filename'."
done

log_info "Finished processing Markdown files."

# 5. Build Hugo site
log_info "Building Hugo site..."
cd "$GIT_REPO_PATH" || exit 1
hugo
if [ $? -ne 0 ]; then
    log_error "Hugo build failed. Please check Hugo output for errors."
    exit 1
fi
log_info "Hugo site built successfully."

# 6. Add changes to Git
log_info "Adding changes to Git..."
git add content/posts/* static/images/posts/* static/docs/* static/downloads/* static/audio/* static/video/*
git add . # Add any other changes
if [ $? -ne 0 ]; then
    log_error "Failed to add changes to Git."
    exit 1
fi
log_info "Changes added to Git."

# 7. Generate Default Commit Message
default_commit_message="Publishing "
if [ ${#processed_files[@]} -gt 0 ]; then
    default_commit_message+="post(s): "
    IFS=', '
    default_commit_message+="${processed_files[*]}"
    unset IFS
else
    default_commit_message+="no new posts"
fi
log_info "Generated default commit message: '$default_commit_message'"

# 8. Prompt for Commit Message
read -p "Enter commit message (leave blank for default: '$default_commit_message'): " custom_commit_message

# Use custom message if provided, otherwise use the default
if [ -z "$custom_commit_message" ]; then
    commit_message="$default_commit_message"
else
    commit_message="$custom_commit_message"
fi
log_info "Using commit message: '$commit_message'"

# 9. Commit changes
log_info "Committing changes..."
git commit -m "$commit_message"
if [ $? -ne 0 ]; then
    log_error "Git commit failed."
    exit 1
fi
log_info "Changes committed."

# 10. Push changes to GitHub
log_info "Pushing changes to GitHub..."
git push origin main
if [ $? -eq 0 ]; then
    log_info "Changes successfully pushed to GitHub. Netlify will now deploy."
else
    log_error "Error pushing changes to GitHub."
    exit 1
fi

log_info "Blog post publishing process complete."

exit 0
