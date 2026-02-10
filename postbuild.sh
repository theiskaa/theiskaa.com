#!/bin/bash
# Post-build script: generates per-route HTML files with correct meta tags
# for social media previews and SEO (crawlers don't execute JS/WASM).
# Run after `trunk build`: trunk build && ./postbuild.sh

set -e

DIST="dist"
POSTS_DIR="posts"
TEMPLATE="$DIST/index.html"

if [ ! -f "$TEMPLATE" ]; then
    echo "Error: $TEMPLATE not found. Run 'trunk build' first."
    exit 1
fi

# Replace meta tags in template using perl (avoids sed escaping issues).
generate_page() {
    local title="$1"
    local description="$2"
    local output="$3"

    mkdir -p "$(dirname "$output")"

    TITLE="$title" DESC="$description" perl -pe '
        BEGIN { $t = $ENV{TITLE}; $d = $ENV{DESC}; }
        s{<title>theiskaa</title>}{<title>$t</title>};
        s{(name="description"\s+content=")theiskaa(")}{$1$d$2};
        s{(property="og:title"\s+content=")theiskaa(")}{$1$t$2};
        s{(property="og:description"\s+content=")theiskaa(")}{$1$d$2};
        s{(name="twitter:title"\s+content=")theiskaa(")}{$1$t$2};
        s{(name="twitter:description"\s+content=")theiskaa(")}{$1$d$2};
    ' "$TEMPLATE" > "$output"
}

# Extract a frontmatter field value from a markdown file.
frontmatter() {
    awk -v key="$1" '
        /^---$/ { n++; next }
        n==1 && $0 ~ "^"key":" { sub("^"key":[ \t]*", ""); print; exit }
        n>=2 { exit }
    ' "$2"
}

# Posts listing page
generate_page "posts - theiskaa" "posts by theiskaa" "$DIST/posts/index.html"
echo "  /posts/index.html"

# Individual post pages
for md in "$POSTS_DIR"/*.md; do
    [ -f "$md" ] || continue

    slug="$(basename "$md" .md)"
    title="$(frontmatter title "$md")"
    description="$(frontmatter description "$md")"

    if [ -n "$title" ]; then
        generate_page "${title} - theiskaa" "$description" "$DIST/posts/${slug}/index.html"
        echo "  /posts/${slug}/index.html"
    fi
done

echo "done"
