pub mod app;
pub mod meta;
pub mod posts;
pub mod routes;
use app::App;

fn main() {
    yew::start_app::<App>();
}
