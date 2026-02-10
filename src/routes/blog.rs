use wasm_bindgen::prelude::*;
use yew::prelude::*;
use yew_router::prelude::*;

use crate::posts::get_posts;
use crate::routes::Route;

#[wasm_bindgen(inline_js = "
export function set_blog_meta(title, description) {
    document.title = title;
    var tags = [
        ['meta[name=\"description\"]', 'name', 'description'],
        ['meta[property=\"og:title\"]', 'property', 'og:title'],
        ['meta[property=\"og:description\"]', 'property', 'og:description'],
        ['meta[name=\"twitter:title\"]', 'name', 'twitter:title'],
        ['meta[name=\"twitter:description\"]', 'name', 'twitter:description']
    ];
    for (var i = 0; i < tags.length; i++) {
        var el = document.querySelector(tags[i][0]);
        var val = tags[i][2].indexOf('title') !== -1 ? title : description;
        if (el) { el.setAttribute('content', val); }
    }
}
")]
extern "C" {
    fn set_blog_meta(title: &str, description: &str);
}

#[function_component(Blog)]
pub fn blog() -> Html {
    set_blog_meta("posts - theiskaa", "posts by theiskaa");
    let posts = get_posts();

    html! {
        <div class="blog-wrapper">
            <div class="blog-container">
                <div class="post-back">
                    <a href="/">{"<- home"}</a>
                </div>
                <h1 class="blog-title">{"posts"}</h1>
                <div class="blog-list">
                    { for posts.iter().map(|post| {
                        let slug = post.slug.to_string();
                        html! {
                            <Link<Route> to={Route::Post { slug }} classes="blog-item-link">
                                <div class="blog-item">
                                    <span class="blog-item-date">{ &post.date }</span>
                                    <h2 class="blog-item-title">{ &post.title }</h2>
                                    <p class="blog-item-desc">{ &post.description }</p>
                                </div>
                            </Link<Route>>
                        }
                    })}
                </div>
            </div>
        </div>
    }
}
