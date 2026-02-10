pub struct Post {
    pub title: String,
    pub date: String,
    pub description: String,
    pub slug: &'static str,
    pub content: String,
}

fn parse_frontmatter(raw: &str) -> (String, String, String, String) {
    let mut title = String::new();
    let mut date = String::new();
    let mut description = String::new();
    let mut content = String::new();

    if raw.starts_with("---") {
        let rest = &raw[3..];
        if let Some(end) = rest.find("---") {
            let frontmatter = &rest[..end];
            content = rest[end + 3..].trim().to_string();

            for line in frontmatter.lines() {
                let line = line.trim();
                if let Some(val) = line.strip_prefix("title:") {
                    title = val.trim().to_string();
                } else if let Some(val) = line.strip_prefix("date:") {
                    date = val.trim().to_string();
                } else if let Some(val) = line.strip_prefix("description:") {
                    description = val.trim().to_string();
                }
            }
        }
    }

    (title, date, description, content)
}

fn make_post(slug: &'static str, raw: &str) -> Post {
    let (title, date, description, content) = parse_frontmatter(raw);
    Post {
        title,
        date,
        description,
        slug,
        content,
    }
}

pub fn get_posts() -> Vec<Post> {
    let mut posts = vec![
        make_post("globe-rendering-system-of-elevens", include_str!("../posts/globe-rendering-system-of-elevens.md")),
        make_post("highlighting-html-in-flutter", include_str!("../posts/highlighting-html-in-flutter.md")),
        make_post("drawing-a-space-debris-around-main-globe-of-elevens", include_str!("../posts/drawing-a-space-debris-around-main-globe-of-elevens.md")),
    ];
    posts.sort_by(|a, b| b.date.cmp(&a.date));
    posts
}

pub fn get_post_by_slug(slug: &str) -> Option<Post> {
    get_posts().into_iter().find(|p| p.slug == slug)
}
