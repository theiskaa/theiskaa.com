use gloo::utils::document;
use yew::prelude::*;
use yew_router::prelude::*;

use crate::posts::get_posts;
use crate::routes::Route;

#[function_component(Blog)]
pub fn blog() -> Html {
    document().set_title("posts - theiskaa");
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
