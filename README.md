# [theiskaa.com](https://theiskaa.com)

The official source code of my personal website. (API/client combined).

### Tech Stack: 
- API: **Go**
- Web: **Rust**, **Yew**
- Rendering: **Custom JSON data instead of markdown and HTML**
- Deployment: **Digital Ocean**
- Hosting: **Cloud Flare**

---

## API
Written in Go and uses firestore as cloud storage by connecting via [firebase admin SDK](https://firebase.google.com/docs/admin/setupxt).
Currently, has two endpoints `/info` and `/posts`. `/info` is the endpoint that is connected to the **Info** page's data.
And `/posts` is the endpoint that manages the blog posts that I wrote.

## Web
Written in Rust and uses [Yew](https://yew.rs) framework. Implements [yew_router](https://yew.rs/docs/next/concepts/router) for routing, [stylist](https://crates.io/crates/stylist) for styling, and custom request service wrapper(dio) to [reqwest](https://crates.io/crates/reqwest) for HTTP requesting.

---