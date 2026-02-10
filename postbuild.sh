#!/bin/bash
# Post-build script: generates per-route HTML files with correct meta tags.
# Run after `trunk build`: trunk build && ./postbuild.sh

set -e

DIST="dist"
POSTS_DIR="posts"
TEMPLATE="$DIST/index.html"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: $TEMPLATE not found. Run 'trunk build' first."
    exit 1
fi

# Generate HTML with replaced meta tags
generate_page() {
    local title="$1"
    local description="$2"
    local output="$3"

    mkdir -p "$(dirname "$output")"

    sed \
        -e "s|<title>theiskaa</title>|<title>${title}</title>|" \
        -e "s|<meta name=\"description\" content=\"theiskaa\">|<meta name=\"description\" content=\"${description}\">|" \
        -e "s|<meta property=\"og:title\" content=\"theiskaa\">|<meta property=\"og:title\" content=\"${title}\">|" \
        -e "s|<meta property=\"og:description\" content=\"theiskaa\">|<meta property=\"og:description\" content=\"${description}\">|" \
        -e "s|<meta name=\"twitter:title\" content=\"theiskaa\">|<meta name=\"twitter:title\" content=\"${title}\">|" \
        -e "s|<meta name=\"twitter:description\" content=\"theiskaa\">|<meta name=\"twitter:description\" content=\"${description}\">|" \
        "$TEMPLATE" > "$output"
}

# Generate /posts listing page
generate_page "posts - theiskaa" "posts by theiskaa" "$DIST/posts/index.html"
echo "  /posts/index.html"

# Generate per-post pages from markdown frontmatter
for md in "$POSTS_DIR"/*.md; do
    [ -f "$md" ] || continue

    slug="$(basename "$md" .md)"
    title=""
    description=""

    while IFS= read -r line; do
        case "$line" in
            "---") ;;
            title:*) title="${line#title: }" ;;
            description:*) description="${line#description: }" ;;
        esac
    done < <(sed -n '2,/^---$/p' "$md")

    if [ -n "$title" ]; then
        generate_page "${title} - theiskaa" "$description" "$DIST/posts/${slug}/index.html"
        echo "  /posts/${slug}/index.html"
    fi
done

echo "done"
