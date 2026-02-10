use yew::prelude::*;
use yew_router::prelude::*;

use crate::routes::Blog;
use crate::routes::Home;
use crate::routes::NotFound;
use crate::routes::PostPage;

#[derive(Clone, Routable, PartialEq)]
pub enum Route {
    #[at("/")]
    Home,

    #[at("/blog")]
    Blog,

    #[at("/blog/:slug")]
    Post { slug: String },

    #[not_found]
    #[at("/404")]
    NotFound,
}

// Route switcher of application.
// Replaces the [current] route with given [Route]
// appropriate page.
pub fn switch(routes: &Route) -> Html {
    match routes {
        Route::Home => {
            html! { <Home/> }
        }

        Route::Blog => {
            html! { <Blog/> }
        }

        Route::Post { slug } => {
            html! { <PostPage slug={slug.clone()} /> }
        }

        Route::NotFound => {
            html! { <NotFound/> }
        }
    }
}
