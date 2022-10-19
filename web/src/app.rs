//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

use stylist::{yew::styled_component, Style};
use yew::prelude::*;

// TODO: add [Inter] font-style import.
const STYLECSS: &str = include_str!("styles/main.css");

#[styled_component(App)]
pub fn app() -> Html {
    let global_style = match Style::new(STYLECSS) {
        Err(e) => return html! { format!("Something went wrong: {}", e) },
        Ok(s) => s,
    };

    html! {
      <div class={global_style}>
        <body>
          <div class="wrapper">
           <div class="columns">
             <div class="main">
               // Profile
               <img class="avatar" src="https://avatars.githubusercontent.com/u/59066341?v=4" alt="My picture" title="profile picture"/>

               // Greeting title
               <p style="margin-top: 0; line-height: 1.2em;">
                 <b>{ "Gamarjoba!" }</b>
                 { " I'm Ismael Shakverdiev." }
               </p>

               // Career
               <p>
                 { "I'm founder of " }
                 <a href="https://insolite.io">{ "Insolite" }</a>
                 { " (open-source software development organization). And, Software Engineering TL at " }
                 <a href="https://jobia.work">{ "Jobia" }</a>
               </p>

               // Projects
               <p>
                 { "I love making open source projects in my free time, here is some of them: " }
                 <a href="https://github.com/theiskaa/mate">{ "mate" }</a>
                 { ", " }
                 <a href="https://github.com/insolite-dev/notya">{ "notya" }</a>
                 { ", " }
                 <a href="https://github.com/theiskaa/field_suggestion">{ "field_suggestion" }</a>
                 { ", " }
                 <a href="https://github.com/theiskaa/Visual-Time">{ "Visual-Time" }</a>
                 { " and etc " }
                 <a href="https://github.com/theiskaa/projects">{ "... " }</a>
               </p>

               <div class="clearfix"></div>

               // Contact
               <h2 id="contact">{"Contact"}</h2>
               <div class="contact">
                 <p>
                   { "I'm multi-polyglot because of my ethnic nationality " }
                   { "That means, I speak four native languages: " }
                   <a href="https://en.wikipedia.org/wiki/Saingilo"> { "Ethnic Ingilo-Georgian" }</a>
                   {", "}
                   { "Georgian, Azerbaijani, and Turkish." }
                 </p>
                 <p>
                   { "You can find me on " }
                   <a href="https://twitter.com/theiskaa">{"Twitter"}</a>
                   {", "}
                   <a href="https://github.com/theiskaa">{"GitHub"}</a>
                   {", "}
                   <a href="https://linkedin.com/in/theiskaa">{"LinkedIn"}</a>
                   {", and "}
                   <a href="https://instagram.com/theiskaa">{"Instagram"}</a>
                   <br />
                    { "> Or send me an shit email " } <a href="mailto:me@theiskaa.com">{ "me@theiskaa.com" }</a>
                   <br />
                   <p> { "> You can also join to "}<a href="https://discord.gg/EJZYDHUq4a">{ "Insolite Community" }</a> { " Discord Server" } </p>
                 </p>
               </div>
             </div>
           </div>
          </div>
          <footer class="footer">
            <p>
            { "Copyright © 2022 Ismael Shakverdiev. " }
            <a href="" title="Privacy Policy">{ "Privacy Policy" }</a>
            </p>
          </footer>
        </body>
      </div>
    }
}
