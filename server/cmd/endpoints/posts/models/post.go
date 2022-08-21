//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package posts

// Post is the main model structure of the posts endpoint.
type Post struct {
	ID          string `json:"id"`          // A unique identification string
	Title       string `json:"title"`       // A descriptive title
	Description string `json:"description"` // A short description
	Cover       string `json:"picture"`     // A relevant cover photo
	Date        string `json:"date"`        // The posting || updating date
	Content     string `json:"content"`     // The body, in Markdown or HTML
}
