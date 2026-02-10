use gloo::utils::document;
use pulldown_cmark::{html::push_html, Options, Parser};
use wasm_bindgen::prelude::*;
use web_sys::Element;
use yew::prelude::*;

use crate::posts::get_post_by_slug;

#[wasm_bindgen(inline_js = "
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
export function set_meta(name, content) {
    var el = document.querySelector('meta[name=\"' + name + '\"]');
    if (el) { el.setAttribute('content', content); }
    else {
        el = document.createElement('meta');
        el.setAttribute('name', name);
        el.setAttribute('content', content);
        document.head.appendChild(el);
    }
}
")]
extern "C" {
    fn render_math(element: &Element);
    fn highlight_code(element: &Element);
    fn set_meta(name: &str, content: &str);
}

/// Extract math blocks (`$$...$$` and `$...$`) from markdown, replacing them
/// with placeholders so pulldown-cmark doesn't mangle LaTeX syntax.
fn protect_math(input: &str) -> (String, Vec<(String, bool)>) {
    let mut result = String::new();
    let mut blocks: Vec<(String, bool)> = Vec::new();
    let bytes = input.as_bytes();
    let len = bytes.len();
    let mut i = 0;

    while i < len {
        if bytes[i] == b'`' {
            // Skip inline code and fenced code blocks
            if i + 2 < len && bytes[i + 1] == b'`' && bytes[i + 2] == b'`' {
                // Fenced code block — find closing ```
                result.push_str("```");
                i += 3;
                loop {
                    if i >= len {
                        break;
                    }
                    if bytes[i] == b'`' && i + 2 < len && bytes[i + 1] == b'`' && bytes[i + 2] == b'`' {
                        result.push_str("```");
                        i += 3;
                        break;
                    }
                    result.push(bytes[i] as char);
                    i += 1;
                }
            } else {
                // Inline code — find closing `
                result.push('`');
                i += 1;
                while i < len && bytes[i] != b'`' {
                    result.push(bytes[i] as char);
                    i += 1;
                }
                if i < len {
                    result.push('`');
                    i += 1;
                }
            }
        } else if bytes[i] == b'$' {
            if i + 1 < len && bytes[i + 1] == b'$' {
                // Display math $$...$$
                i += 2;
                let mut math = String::new();
                let mut closed = false;
                while i < len {
                    if bytes[i] == b'$' && i + 1 < len && bytes[i + 1] == b'$' {
                        i += 2;
                        closed = true;
                        break;
                    }
                    math.push(bytes[i] as char);
                    i += 1;
                }
                if closed {
                    let idx = blocks.len();
                    blocks.push((math, true));
                    result.push_str(&format!("\n\nMATH_PLACEHOLDER_{}\n\n", idx));
                } else {
                    result.push_str("$$");
                    result.push_str(&math);
                }
            } else {
                // Inline math $...$
                i += 1;
                let mut math = String::new();
                let mut closed = false;
                while i < len {
                    if bytes[i] == b'$' {
                        i += 1;
                        closed = true;
                        break;
                    }
                    if bytes[i] == b'\n' && i + 1 < len && bytes[i + 1] == b'\n' {
                        break; // Don't span across blank lines
                    }
                    math.push(bytes[i] as char);
                    i += 1;
                }
                if closed && !math.is_empty() {
                    let idx = blocks.len();
                    blocks.push((math, false));
                    result.push_str(&format!("MATH_PLACEHOLDER_{}", idx));
                } else {
                    result.push('$');
                    result.push_str(&math);
                }
            }
        } else {
            result.push(bytes[i] as char);
            i += 1;
        }
    }

    (result, blocks)
}

fn html_escape(s: &str) -> String {
    s.replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
}

/// Replace placeholders in the HTML output with KaTeX-renderable elements.
fn restore_math(html: &str, blocks: &[(String, bool)]) -> String {
    let mut out = html.to_string();
    for (idx, (content, display)) in blocks.iter().enumerate() {
        let placeholder = format!("MATH_PLACEHOLDER_{}", idx);
        let escaped = html_escape(content);
        if *display {
            let tag = format!("<div class=\"math-display\" data-math=\"{}\"></div>", escaped);
            // Try to unwrap the <p> wrapper pulldown-cmark adds around block placeholders
            let p_wrapped = format!("<p>{}</p>", placeholder);
            if out.contains(&p_wrapped) {
                out = out.replace(&p_wrapped, &tag);
            } else {
                out = out.replace(&placeholder, &tag);
            }
        } else {
            let tag = format!("<span class=\"math-inline\" data-math=\"{}\"></span>", escaped);
            out = out.replace(&placeholder, &tag);
        }
    }
    out
}

fn render_markdown(raw: &str) -> String {
    let (protected, math_blocks) = protect_math(raw);

    let mut options = Options::empty();
    options.insert(Options::ENABLE_STRIKETHROUGH);
    options.insert(Options::ENABLE_TABLES);

    let parser = Parser::new_ext(&protected, options);
    let mut html_output = String::new();
    push_html(&mut html_output, parser);

    restore_math(&html_output, &math_blocks)
}

#[derive(Properties, Clone, PartialEq)]
pub struct PostProps {
    pub slug: String,
}

#[function_component(PostPage)]
pub fn post_page(props: &PostProps) -> Html {
    match get_post_by_slug(&props.slug) {
        Some(post) => {
            document().set_title(&format!("{} - theiskaa", &post.title));
            set_meta("description", &post.description);

            let html_output = render_markdown(&post.content);
            let content_ref = use_node_ref();

            {
                let content_ref = content_ref.clone();
                use_effect_with_deps(
                    move |html: &String| {
                        if let Some(el) = content_ref.cast::<Element>() {
                            el.set_inner_html(html);
                            render_math(&el);
                            highlight_code(&el);
                        }
                        || ()
                    },
                    html_output,
                );
            }

            html! {
                <div class="post-wrapper">
                    <div class="post-container">
                        <div class="post-back">
                            <a href="/posts">{"<- posts"}</a>
                        </div>
                        <div class="post-header">
                            <h1 class="post-title">{ &post.title }</h1>
                            <span class="post-date">{ &post.date }</span>
                        </div>
                        <div class="post-content" ref={content_ref} />
                    </div>
                </div>
            }
        }
        None => {
            html! {
                <div class="overlay">
                    <div class="center-div">
                        <div class="text-container">
                            <div class="not-found">
                                <a href="/posts" alt="404 | Not found">{"404"}</a>
                            </div>
                        </div>
                    </div>
                </div>
            }
        }
    }
}
