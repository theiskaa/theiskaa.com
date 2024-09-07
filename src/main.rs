pub mod app;
pub mod routes;
use app::App;

fn main() {
    yew::start_app::<App>();
}
