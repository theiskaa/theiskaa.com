use crate::components::Header;
use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
       <>
           <Header/>
           <div class="nav">

               <div class="a">
                  <img src="public/fav.png" alt="Profile Avatar"/>
               </div>
               <div class="a">
                  <p>{"Ismael Shakverdiev"}</p>
               </div>

               <div>
               </div>

               <div>
               </div>

           </div>
       </>
    }
}
