use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
        <div class="wrapper">
            <div class="center">
                <h1 class="motto">{"Libertas aut mors"}</h1>
                <div class="links">
                    <a href="/blog">{"posts"}</a>
                    <span class="dot"></span>
                    <a href="https://github.com/theiskaa">{"github"}</a>
                    <span class="dot"></span>
                    <a href="https://twitter.com/theiskaa">{"twitter"}</a>
                    <span class="dot"></span>
                    <a href="https://instagram.com/theiskaa">{"instagram"}</a>
                </div>
                <div class="links small">
                    <a href="https://jobia.org">{"jobia.org"}</a>
                    <span class="dot"></span>
                    <a href="https://11s.art">{"11s.art"}</a>
                    <span class="dot"></span>
                    <a href="https://reeed.io">{"reeed.io"}</a>
                </div>
            </div>
        </div>
    }
}
