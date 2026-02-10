
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
