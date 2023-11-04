use yew::prelude::*;

#[function_component(NotFound)]
pub fn not_found() -> Html {
    html! {
       <div class="overlay">
          <div class="center-div">
             <div class="text-container">
                <div class="not-found">
                  <a href="/" alt="404 | Not found">{"404"}</a>
                </div>
             </div>
          </div>
       </div>
    }
}
