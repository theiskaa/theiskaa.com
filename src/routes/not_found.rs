use yew::prelude::*;

#[function_component(NotFound)]
pub fn not_found() -> Html {
    html! {
        <div class="not-found-wrapper">
            <div class="not-found-container">
                <h1 class="not-found-code">{"404"}</h1>
                <p class="not-found-text">{"page not found"}</p>
                <a href="/" class="not-found-link">{"<- home"}</a>
            </div>
        </div>
    }
}
