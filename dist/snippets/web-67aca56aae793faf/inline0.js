
export function render_math(element) {
    if (!window.katex) return;
    var els = element.querySelectorAll('.math-display, .math-inline');
    var i = 0;
    function batch() {
        var end = Math.min(i + 8, els.length);
        for (; i < end; i++) {
            try {
                katex.render(els[i].getAttribute('data-math'), els[i], {
                    displayMode: els[i].classList.contains('math-display'),
                    throwOnError: false
                });
            } catch(e) {}
        }
        if (i < els.length) requestAnimationFrame(batch);
    }
    requestAnimationFrame(batch);
}
export function highlight_code(element) {
    if (!window.hljs) return;
    requestAnimationFrame(function() {
        element.querySelectorAll('pre code').forEach(function(block) { hljs.highlightElement(block); });
    });
}
export function set_page_meta(title, description) {
    document.title = title;
    var selectors = [
        ['meta[name="description"]', 'name', 'description'],
        ['meta[property="og:title"]', 'property', 'og:title'],
        ['meta[property="og:description"]', 'property', 'og:description'],
        ['meta[name="twitter:title"]', 'name', 'twitter:title'],
        ['meta[name="twitter:description"]', 'name', 'twitter:description']
    ];
    for (var i = 0; i < selectors.length; i++) {
        var el = document.querySelector(selectors[i][0]);
        var val = selectors[i][2].indexOf('title') !== -1 ? title : description;
        if (el) { el.setAttribute('content', val); }
        else {
            el = document.createElement('meta');
            el.setAttribute(selectors[i][1], selectors[i][2]);
            el.setAttribute('content', val);
            document.head.appendChild(el);
        }
    }
}
