pub fn set_meta(title: &str, description: &str) {
    let document = match web_sys::window().and_then(|w| w.document()) {
        Some(d) => d,
        None => return,
    };

    document.set_title(title);

    let tags: &[(&str, &str)] = &[
        ("meta[name=\"description\"]", description),
        ("meta[property=\"og:title\"]", title),
        ("meta[property=\"og:description\"]", description),
        ("meta[name=\"twitter:title\"]", title),
        ("meta[name=\"twitter:description\"]", description),
    ];

    for &(selector, value) in tags {
        if let Ok(Some(el)) = document.query_selector(selector) {
            let _ = el.set_attribute("content", value);
        }
    }
}
