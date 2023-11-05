use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
       <div class="overlay">
          <div class="center-div">
             <div class="text-container">
               <a href="https://github.com/theiskaa/theiskaa/blob/main/me.md" alt="me">{"me"}</a>
               <p>{ " . " }</p>
               <a href="https://instagram.com/theiskaa" alt="photos">{"photos"}</a>
               <p>{ " . " }</p>
               <a href="https://twitter.com/theiskaa" alt="posts">{"tweets"}</a>
               <p>{ " . " }</p>
               <a href="https://insolite.io" alt="insolite">{"insolite"}</a>
             </div>
          </div>
       </div>
    }
}
