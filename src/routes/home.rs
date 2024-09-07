use yew::prelude::*;

#[function_component(Home)]
pub fn home() -> Html {
    html! {
            <div class="body">
                <div class="container">
                    <div class="profile-section">
                        <img src="public/fav.png" alt="Profile Avatar" class="profile-pic" />
                        <div class="profile-info">
                            <h1>{"Ismael Sh"}</h1>
                            <p class="role">
                                {"founder "}
                                <a href="https://insolite.io" alt="insolite">{"insolite.io"}</a>
                                {" founding member of "}
                                <a href="https://lite.jobia.work" alt="jobia">{"lite.jobia.work"}</a>
                            </p>
                            // founder https://insolite.io • founding member of https://lite.jobia.work
                        </div>
                    </div>

                    <div class="about-text">
                        <p>{"Hey There! I'm Ismael"}</p>
                        <p>
                            {""}
                        </p>
                    </div>

                    <hr class="dotted-divider"/>

                    <div class="bio">
                        <p>
                            {""}
                        </p>
                        <p>
                            {""}
                        </p>
                    </div>
                </div>
            </div>
        }
}
