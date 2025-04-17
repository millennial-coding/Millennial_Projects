#!/bin/bash

# --- Configuration ---
GIT_REPO_PATH="/home/kyleh34/Documents/Obsidian_Blog_Files/Millennial_Projects"
HUGO_CONTENT_PATH="$GIT_REPO_PATH/content/posts"
HUGO_STATIC_IMAGES="$GIT_REPO_PATH/static/images"
OBSIDIAN_VAULT_ROOT="/home/kyleh34/Documents/Obsidian_Blog_Files" # Assuming this is the root of your Obsidian vault
OBSIDIAN_READY_PATH="/home/kyleh34/Documents/Obsidian_Blog_Files/Blog Posts Archive/Ready to Push/" # To construct source path for moving
OBSIDIAN_REMOVED_POSTS="/home/kyleh34/Documents/Obsidian_Blog_Files/Blog Posts Archive/Removed Blog Posts/" # New folder for removed posts
# --- End Configuration ---

log_info() { echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $1"; }
log_error() { echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $1" >&2; }
log_warning() { echo "$(date '+%Y-%m-%d %H:%M:%S') [WARNING] $1"; }
check_directory() { if [ ! -d "$1" ]; then log_error "Dir not found: $1"; exit 1; fi }

check_directory "$HUGO_CONTENT_PATH"
check_directory "$HUGO_STATIC_IMAGES"
check_directory "$OBSIDIAN_VAULT_ROOT"
check_directory "$OBSIDIAN_READY_PATH"
check_directory "$OBSIDIAN_REMOVED_POSTS"
cd "$GIT_REPO_PATH" || { log_error "Failed to change directory to '$GIT_REPO_PATH'"; exit 1; }

if [ -z "$1" ]; then
  log_error "Please provide the slug of the post to remove."
  exit 1
fi

REMOVE_SLUG="$1"
post_md_path="$HUGO_CONTENT_PATH/$REMOVE_SLUG.md"
obsidian_source_path="$OBSIDIAN_READY_PATH/${REMOVE_SLUG}.md" # Construct path in Ready to Push

if [ ! -f "$post_md_path" ]; then
  log_error "Post with slug '$REMOVE_SLUG' not found at '$post_md_path'."
  exit 1
fi

log_info "Processing post removal: $REMOVE_SLUG"

# 1. Extract image filenames from the Markdown content
image_files_to_remove=()
while IFS= read -r image_markdown; do
  image_path_relative=$(echo "$image_markdown" | sed -E 's/!\[.*?\]\((.*?)\)/\1/')
  image_filename=$(basename "$image_path_relative")
  image_files_to_remove+=("$image_filename")
done < <(grep -oP "!\[.*?\]\(([^)]+)\)" "$post_md_path")

# 2. Delete the Markdown file and remove it from Git
log_info "Deleting Markdown file from Hugo: $post_md_path"
if ! rm "$post_md_path"; then
  log_error "Failed to delete Markdown file: $post_md_path."
  exit 1 # Stop if we can't delete the main file
fi
if ! git rm "content/posts/$REMOVE_SLUG.md"; then
  log_warning "Failed to remove Markdown file from Git. You might need to do this manually."
fi

# 3. Delete the associated image files and remove them from Git
if [ ${#image_files_to_remove[@]} -gt 0 ]; then
  log_info "Deleting associated images from Hugo:"
  for image_file in "${image_files_to_remove[@]}"; do
    image_path_to_delete="$HUGO_STATIC_IMAGES/$image_file"
    if [ -f "$image_path_to_delete" ]; then
      log_info "  - Deleting image: $image_path_to_delete"
      if ! rm "$image_path_to_delete"; then
        log_warning "    - Failed to delete image: $image_path_to_delete."
      else
        if ! git rm "static/images/posts/$image_file"; then
          log_warning "    - Failed to remove image '$image_file' from Git. You might need to do this manually."
        fi
      fi
    else
      log_warning "  - Image not found in Hugo: $image_path_to_delete"
    fi
  done
else
  log_info "No images found linked in the Markdown file."
fi

# 4. Move the original Obsidian post to the "Removed Blog Posts" folder
if [ -f "$obsidian_source_path" ]; then
  log_info "Moving original Obsidian post to '$OBSIDIAN_REMOVED_POSTS'"
  mv "$obsidian_source_path" "$OBSIDIAN_REMOVED_POSTS"
  if [ $? -ne 0 ]; then
    log_warning "Failed to move Obsidian post to '$OBSIDIAN_REMOVED_POSTS'. Check permissions."
  fi
else
  log_warning "Original Obsidian post not found at '$obsidian_source_path'."
fi

# 5. Commit changes
log_info "Committing changes..."
commit_message="Remove blog post '$REMOVE_SLUG' and associated images"
git commit -m "$commit_message"
if [ $? -ne 0 ]; then
  log_error "Git commit failed."
  exit 1 # Stop if commit fails
fi
log_info "Changes committed."

# 6. Push changes
log_info "Pushing changes..."
git push origin main
if [ $? -ne 0 ]; then
  log_error "Error pushing changes to GitHub."
  exit 1 # Stop if push fails
fi
log_info "Changes successfully pushed."

log_info "Blog post removal process complete."

exit 0
