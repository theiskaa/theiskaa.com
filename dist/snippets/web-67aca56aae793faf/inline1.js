
export function set_blog_meta(title, description) {
    document.title = title;
    var tags = [
        ['meta[name="description"]', 'name', 'description'],
        ['meta[property="og:title"]', 'property', 'og:title'],
        ['meta[property="og:description"]', 'property', 'og:description'],
        ['meta[name="twitter:title"]', 'name', 'twitter:title'],
        ['meta[name="twitter:description"]', 'name', 'twitter:description']
    ];
    for (var i = 0; i < tags.length; i++) {
        var el = document.querySelector(tags[i][0]);
        var val = tags[i][2].indexOf('title') !== -1 ? title : description;
        if (el) { el.setAttribute('content', val); }
    }
}
