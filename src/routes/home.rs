use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
        <div class="wrapper">
            <div class="body">
                <div class="container">
                    <div class="profile-section">
                        <img src="public/profile.jpg" alt="Profile Avatar" class="profile-pic" />
                        <div class="profile-info">
                            <h1>{"Ismael Shakverdiev"}</h1>
                            <p class="role">
                                {"senior engineer at "}
                                <a href="https://tnet.ge" alt="tnet">{"tnet.ge"}</a>
                                {". crafting "}
                                <a href="https://sarke.org" alt="sarke">{"sarke.org"}</a>
                                {". founding member of "}
                                <a href="https://jobia.work" alt="jobia">{"jobia.work"}</a>
                            </p>
                        </div>
                    </div>
                    <div class="links">
                        <p>
                            <a href="https://github.com/theiskaa" alt="github">{"github"}</a>
                            { " . " }
                            <a href="https://instagram.com/theiskaa" alt="photos">{"photos"}</a>
                            { " . " }
                            <a href="https://twitter.com/theiskaa" alt="posts">{"tweets"}</a>
                        </p>
                    </div>
                    <div class="about-text">
                        <p>
                            {"I'm a self-taught software engineer with a passion that started in my early teens. Beginning my professional journey at 15. Outside of work, I enjoy exploring topics in consciousness, building intuition on mathematical concepts, and contributing to open-source projects, which can be found on my "}
                            <a href="https://github.com/theiskaa" alt="github">{"github"}</a>
                            {" profile."}
                        </p>
                        <hr class="dotted-divider"/>
                        <h2>{"Experience"}</h2>
                        <p>
                          {"Currently, I'm working at "}
                          <a href="https://tnet.ge/en" alt="tnet.ge">{"TNET"}</a>
                          {", the largest technology company in Georgia. As a Senior Software Engineer in the "}
                          <a href="https://tkt.ge/en" alt="tkt.ge">{"tkt.ge"}</a>
                          {" mobile application department, I'm leading the team responsible for building the cross-platform mobile application from the ground up."}
                        </p>
                        <p>
                          {"From October 2023 to September 2024, I worked as a Software Engineer at "}
                          <a href="https://www.l3vels.xyz/" alt="L3VELS">{"L3VELS"}</a>
                          {" and later at "}
                          <a href="https://datura.ai" alt="datura.ai">{"datura.ai"}</a>
                          {", contributing to AI platforms like "}
                          <a href="https://github.com/l3vels/L3AGI" alt="L3AGI">{"L3AGI"}</a>
                          {" and "}
                          <a href="https://chi.datura.ai" alt="Datura">{"Datura"}</a>
                          {". I focused on backend development, infrastructure optimization, and creating intelligent search tools."}
                        </p>
                        <p>
                          {"Before that, I was a Senior Software Engineer at "}
                          <a href="https://zencode.io" alt="Zencode">{"Zencode"}</a>
                          {", working on "}
                          <a href="https://payme.zencode.io" alt="Zenbank">{"Payme"}</a>
                          {", an internet banking application. I built secure authentication systems, encrypted cross-platform local database solutions, and implemented real-time communication features."}
                        </p>
                        <p>
                          {"As a founding member of "}
                          <a href="https://jobia.work" alt="Jobia">{"Jobia"}</a>
                          {", I \"currently\" lead all technical aspects of the platform that intelligently matches job seekers with opportunities based on skills and interests. I manage the entire technical infrastructure, from development to deployment. Earlier in the company's journey, I served as a Senior Engineer before taking on my current leadership role."}
                        </p>
                        <p>
                          {"My professional journey began with an internship at "}
                          <a href="https://github.com/lomsa-com" alt="Lomsa">{"Lomsa"}</a>
                          {", where I designed and developed core features for their mobile application ecosystem. I was also an active contributor to "}
                          <a href="https://github.com/lomsa-com/http-mock-adapter" alt="http_mock_adapter">{"http_mock_adapter"}</a>
                          {", their widely-adopted open-source HTTP testing library that simplifies API development workflows. This experience provided me with a strong foundation in both product development and open-source collaboration."}
                        </p>
                    </div>

                    <hr class="dotted-divider"/>

                    <div class="bio">
                        <p>
                            {"Feel free to reach out at "}
                            <a href="mailto:me@theiskaa.com" alt="email">{"me@theiskaa.com"}</a>
                            {" or find me on "}
                            <a href="https://x.com/theiskaa" alt="email">{"@theiskaa"}</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    }
}
