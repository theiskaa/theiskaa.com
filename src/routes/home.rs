use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
        <div class="wrapper">
            <div class="body">
                <div class="container">
                    <div class="profile-section">
                        <img src="public/fav.png" alt="Profile Avatar" class="profile-pic" />
                        <div class="profile-info">
                            <h1>{"Ismael Shakverdiev"}</h1>
                            <p class="role">
                                {"founder "}
                                <a href="https://insolite.io" alt="insolite">{"insolite.io"}</a>
                                {" founding member of "}
                                <a href="https://lite.jobia.work" alt="jobia">{"lite.jobia.work"}</a>
                            </p>
                        </div>
                    </div>
                    <div class="about-text">
                        <p>
                            {"I'm a self-taught software engineer who started programming at 13. With over a decade of experience, I began working professionally at 15, and now, at 19 years old, I've gained hands-on expertise across various startups and projects."}
                        </p>
                        <p>
                            {"Since my early start, I’ve contributed to multiple innovative open-source initiatives. Alongside my startup at Insolite, we've released 7 Flutter/Dart packages, which can be found "}
                            <a href="https://pub.dev/publishers/insolite.io/packages" alt="insolite pub.dev">{"at pub.dev page of insolite"}</a>
                            {" or "}
                            <a href="https://pub.dev/publishers/insolite.io/packages" alt="my pub.dev">{"my personal pub.dev page"}</a>
                            {"."}
                        </p>
                        <p>
                            {"Here is a small list of my open source projects:"}
                        </p>
                        <ul>
                            <li><a href="https://pub.dev/packages/hidable" alt="Hidable">{"Hidable"}</a> {" (Flutter/Dart) - A Flutter widget for scroll-to-hide functionality."}</li>
                            <li><a href="https://pub.dev/packages/field_suggestion" alt="Field Suggestion">{"Field Suggestion"}</a> {"(Flutter/Dart) - A lightweight, customizable search field for Flutter."}</li>
                            <li><a href="https://pub.dev/packages/widget_slider" alt="Widget Slider">{"Widget Slider"}</a> {"(Flutter/Dart) - A fast and user-friendly animated slider list widget for Flutter."}</li>
                            <li><a href="https://github.com/insolite-dev/notya" alt="Notya">{"Notya"}</a> {"(Go, Flutter/Dart, Firebase) - A versatile command-line notes app with cross-platform mobile integration."}</li>
                            <li><a href="https://github.com/theiskaa/replace" alt="Replace">{"Replace"}</a> {"(C) - A versatile tool that enables you to perform efficient replacement operations within specified files, with a recursive replacement algorithm."}</li>
                            <li><a href="https://github.com/theiskaa/mate" alt="Mate">{"Mate"}</a> {"(Rust) - A powerful arithmetic expression interpreter and calculator in Rust, published on Crates.io."}</li>
                            <li><a href="https://github.com/theiskaa/hivetime" alt="Hivetime">{"Hivetime"}</a> {"(Rust) - A straightforward interpreter and calculator designed for short-time syntax, primarily used in Jira work logs."}</li>
                            <li><a href="https://github.com/theiskaa/mdPdf" alt="mdPdf">{"mdPdf"}</a> {"(Rust) - A simple tool and library to create/transpile Markdown to PDF."}</li>
                        </ul>

                        <h2>{"Past Work"}</h2>
                        <p>
                            {"From 2023 to 2024, I worked as a Software Engineer at "}
                            <a href="https://www.l3vels.xyz/" alt="L3VELS">{"L3VELS"}</a>
                            {" and later at "}
                            <a href="https://datura.ai" alt="Datura.ai">{"Datura.ai"}</a>
                            {", where my team and I contributed to cutting-edge AI platforms, including "}
                            <a href="https://github.com/l3vels/L3AGI" alt="L3AGI">{"l3agi"}</a>
                            {" and "}
                            <a href="https://datura.ai" alt="Datura">{"Datura"}</a>
                            {" (Bittensor’s Subnet 22). My work primarily focused on backend development and AWS infrastructure, including Lambda, SQS, and CloudFormation. I played an integral role in the configuration and optimization of systems for miners and validators, ensuring scalability and efficiency. Additionally, I led the development of an advanced image categorization tool similar to Google Photos' AI-powered search, enhancing the platform's search capabilities and user experience."}
                        </p>
                        <p>
                            {"Before that, I served as a Senior Mobile Engineer at "}
                            <a href="https://zencode.io" alt="Zencode">{"Zencode"}</a>
                            {", where I worked on fintech projects. I developed a highly secure local authentication system, resistant to reverse engineering attacks, safeguarding user data at every level. I also built an in-app chat system with real-time communication features and integrated Firebase Cloud Messaging for seamless and lag-free notifications. Moreover, I implemented deep linking strategies by bridging native Android/iOS code with Flutter, which enhanced the app’s functionality and user experience across platforms."}
                        </p>
                        <p>
                            {"As a founding member of "}
                            <a href="https://lite.jobia.work" alt="Jobia">{"Jobia"}</a>
                            {", I am responsible for all technical aspects, from building the application from the ground up, implementing specific algorithms to match users to vacancies based on their soft skills and interests, managing teams, to deploying the application. Every issue or problem on the website or mobile application is ultimately my responsibility."}
                        </p>
                        <p>
                            {"During my internship at "}
                            <a href="https://lomsa.com" alt="Lomsa">{"Lomsa"}</a>
                            {", I was responsible for designing and developing core pages for their mobile app, such as the homepage, login page, and settings page. I implemented essential API functionality, including creating custom API keys and managing WebSocket connections to handle concurrent users. I also contributed to their open-source project, "}
                            <a href="https://github.com/lomsa-dev/http-mock-adapter" alt="http_mock_adapter">{"http_mock_adapter"}</a>
                            {", a popular HTTP testing tool that streamlines API testing for developers."}
                        </p>
                    </div>

                    <hr class="dotted-divider"/>

                    <div class="bio">
                        <p>
                            {"My journey from a programming enthusiast to a professional developer, now at almost 19 years old, has shaped me into a versatile engineer with a passion for solving problems and building tools that make a difference. If you’d like to collaborate or learn more, feel free to reach out at "}
                            <a href="mailto:me@theiskaa.com" alt="email">{"me@theiskaa.com"}</a>
                            {"."}
                        </p>
                    </div>
                </div>
            </div>
        </div>
    }
}
