//
// This source code is distributed under the terms of Bad Code License.
// You are forbidden from distributing software containing this code to
// end users, because it is bad.
//

package info

// Info is the main model of the info endpoint.
type Info struct {
	Picture string `json:"picture"`
	Name    string `json:"name"`
	Bio     string `json:"bio"`
	Links   []Link `json:"links"`
}
