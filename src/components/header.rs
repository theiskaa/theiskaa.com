use yew::prelude::*;

#[function_component(Header)]
pub fn header() -> Html {
    html! {
       <div class="header-container">
           <p>{"home"}</p>
           <p>{"blog"}</p>
       </div>
    }
}
