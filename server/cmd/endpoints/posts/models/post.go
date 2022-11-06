//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package posts

import (
	"encoding/json"

	"github.com/mitchellh/mapstructure"
)

// Post is the main model structure of the posts endpoint.
type Post struct {
	ID          string `json:"id"`
	Title       string `json:"title"`
	Description string `json:"description"`
	Cover       string `json:"cover"`
	Date        string `json:"date"`
	Content     []Href `json:"content"`
}

// The content token reference model.
// Which is a dynamic structure that could represent:
// - text(normal/linked)
// - image
// - code-snippet
//
// Each that representation should be handled by [Href]'s [Type].
// And [Src] of [Href] is the main source of value.
type Href struct {
	// Type is a field that represents the rendering style of [Href].
	//
	// Could be:
	//  - text
	//  - image
	//  - code
	Type string `json:"typ"`

	// Src is a field that used as source of content that has to be rendered.
	Src string `json:"src"`

	// Style is a font-style identifier of [Src] field.
	// > In case of [Type] being any kind of text type.
	//
	// Could be:
	//  - bold
	//  - italic
	//  - strong
	Style string `json:"style"`

	// The reference URL provider for [Src].
	// > In case of [Type] being linked text type. <text>.
	//
	// same approach of `<a href="http://">{Src}</a>`
	// but in go structure model.
	URL string `json:"url"`
}

// Takes byte array value of request body,
// and translates it to valid representation of [Post] map.
func TransformPostBody(body []byte) map[string]interface{} {
	var data map[string]interface{}
	json.Unmarshal(body, &data)

	var post Post
	mapstructure.Decode(data, &post)

	return post.ToJson()
}

// Takes byte array value of request body,
// and translates it to valid representation of [Href] map.
func TransformHrefBody(body []byte) map[string]interface{} {
	var data map[string]interface{}
	json.Unmarshal(body, &data)

	var href Href
	mapstructure.Decode(data, &href)

	return href.ToJson()
}

// ToJson converts the [Post] structure to map value.
func (p *Post) ToJson() map[string]interface{} {
	res, _ := json.Marshal(p)

	m := make(map[string]interface{})
	json.Unmarshal(res, &m)

	return m
}

// ToJson converts the [Href] structure to map value.
func (h *Href) ToJson() map[string]interface{} {
	res, _ := json.Marshal(h)

	m := make(map[string]interface{})
	json.Unmarshal(res, &m)

	return m
}
