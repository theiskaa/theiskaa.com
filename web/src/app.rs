//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

use stylist::{yew::styled_component, Style};
use yew::prelude::*;

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

               // Bio & Career
               <p>
                 { "I'm a baby, language agnostic software engineer, with almost 3 year experience in programming and designing. +
                   (I've 17 year experience in general life)." }
                 <br />
                 {"I founded "}
                 <a href="https://insolite.io">{"Insolite"}</a>
                 { " startup/organization for doing open source projects with an organized team. " }
                 { "Currently, I'm working at " }
                 <a href="https://jobia.work">{ "Jobia" }</a>
                 { " as a software engineering team lead."}
               </p>

               <div class="clearfix"></div>

               // Contact
               <h2 id="contact">{"Contact"}</h2>
               <div class="contact">
                 <p>
                   { "You can find me on " }
                   <a href="https://twitter.com/theiskaa">{"Twitter"}</a>
                   {", "}
                   <a href="https://github.com/theiskaa">{"GitHub"}</a>
                   {", "}
                   <a href="https://linkedin.com/in/theiskaa">{"LinkedIn"}</a>
                   {", and "}
                   <a href="https://instagram.com/theiskaa">{"Instagram"}</a>
                   {"."}
                   <br />
                   <p>
                    {" Never hesitate to send me an email at "}
                    <a href="mailto:me@theiskaa.com"> {"me@theiskaa.com"} </a>
                    {" I love getting email from you."}
                   </p>
                   <p>
                     { "I'm multi-polyglot because of my ethnic nationality. " }
                     { "that means I speak four native languages: " }
                     <a href="https://en.wikipedia.org/wiki/Saingilo"> { "Ingiloan dialect" }</a>
                     { " of Georgian, Georgian, Azerbaijani, and Turkish." }
                   </p>
                   <p> { "• You can also join to "}<a href="https://discord.gg/EJZYDHUq4a">{ "Insolite Community" }</a> { " Discord server." } </p>
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
