use yew::prelude::*;
use chrono::{Utc, NaiveDate};

#[function_component(Home)]
pub fn home() -> Html {
    let birth_date = NaiveDate::from_ymd_opt(2004, 12, 3).unwrap();
    let today = Utc::now().date_naive();
    let age = today.years_since(birth_date).unwrap_or(0);

    html! {
        <div class="wrapper">
            <div class="body">
                <div class="container">
                    <div class="profile-section">
                        <img src="public/profile.png" alt="Profile Avatar" class="profile-pic" />
                        <div class="profile-info">
                            <h1>{"Ismael Shakverdiev"}</h1>
                            <p class="role">
                                {"senior engineer at "}
                                <a href="https://tnet.ge" alt="tnet">{"tnet.ge"}</a>
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
                            {"I'm a self-taught software engineer who started programming at 13. With over a decade of experience, I began working professionally at 15, and now, at "}{age}{" years old, I've gained hands-on expertise across various startups and projects."}
                        </p>
                        <p>
                            {"I spend a large part of my free time thinking about consciousness, catching up on papers about artificial intelligence, building intuition on mathematical fundamentals, and working on open-source projects, which could be found on my "}
                            <a href="https://github.com/theiskaa" alt="github">{"github"}</a>
                            {" profile."}
                        </p>
                        <hr class="dotted-divider"/>
                        <p>
                          {"From October 2024, I started working at "}
                          <a href="https://tnet.ge/en" alt="tnet.ge">{"TNET"}</a>
                          {", the largest technology company in Georgia. As a Senior Software Engineer in the "}
                          <a href="https://tkt.ge/en" alt="tkt.ge">{"tkt.ge"}</a>
                          {" mobile application department, where I am leading the team responsible for building the application from the ground up."}
                        </p>
                        <h2>{"Past Work"}</h2>
                        <p>
                          {"From October 2023 to September 2024, I worked as a Software Engineer at "}
                          <a href="https://www.l3vels.xyz/" alt="L3VELS">{"L3VELS"}</a>
                          {" and later at "}
                          <a href="https://datura.ai" alt="datura.ai">{"datura.ai"}</a>
                          {", where my team and I contributed to artificial intelligence platforms, including "}
                          <a href="https://github.com/l3vels/L3AGI" alt="L3AGI">{"L3AGI"}</a>
                          {" and "}
                          <a href="https://chi.datura.ai" alt="Datura">{"Datura"}</a>
                          {" (bittensor’s subnet 22). My work primarily focused on backend development and AWS infrastructure, such as Lambda, SQS, and CloudFormation. I played a key role in configuring and optimizing systems for miners and validators to ensure scalability and efficiency. I also led the development of an advanced image categorization tool, similar to Google Photos' AI-powered search, which significantly enhanced the platform's search capabilities and user experience, and more."}
                        </p>
                        <p>
                          {"Before that, I was a Senior Software Engineer at "}
                          <a href="https://zencode.io" alt="Zencode">{"Zencode"}</a>
                          {", where I worked with the mobile engineering team on "}
                          <a href="https://payme.zencode.io" alt="Zenbank">{"Payme"}</a>
                          {", an internet bank. I developed a highly secure local authentication system resistant to reverse engineering, ensuring user data protection at every level. I implemented a highly secure local database infrastructure with encryption at rest and in transit. Additionally, I built an in-app chat system with real-time communication features using WebSockets. I programmed native notification handling plugins for both Android and iOS, and designed the entire routing structure and deep linking strategies by bridging native Android/iOS code with Flutter, and to many others."}
                        </p>
                        <p>
                          {"Currently, as a founding member of "}
                          <a href="https://jobia.work" alt="Jobia">{"Jobia"}</a>
                          {", I am responsible for all technical aspects—building the application from the ground up, implementing complex algorithms to match users with vacancies based on their soft skills and interests, managing engineering teams, and more. Any issue or problem with the website or mobile application ultimately falls under my responsibility."}
                          <br/>
                          {" Previously, I was a Senior Software Engineer at Jobia and a core member of the team, overseeing web, mobile, backend, DevOps, and more. Unfortunately, Jobia went bankrupt, unable to secure further investment, and the startup shut down."}
                        </p>
                        <p>
                          {"During my internship at "}
                          <a href="https://lomsa.com" alt="Lomsa">{"Lomsa"}</a>
                          {", I was responsible for designing and developing core pages for their mobile application. I implemented essential API functionality, including creating custom API keys and managing WebSocket connections to handle concurrent processes. I also contributed to their open-source project, "}
                          <a href="https://github.com/lomsa-dev/http-mock-adapter" alt="http_mock_adapter">{"http_mock_adapter"}</a>
                          {", a popular HTTP testing tool that simplifies API testing for developers. Additionally, I worked on creating RenderBox-based widgets, including nested widget grouping and folder structures."}
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
