//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package info

import (
	"encoding/json"

	"github.com/mitchellh/mapstructure"
)

// Info is the main model of the info endpoint.
type Info struct {
	Picture  string `json:"picture"`
	Greeting []Link `json:"greeting"`
	Career   []Link `json:"career"`
	Contact  []Link `json:"contact"`
}

// Link is a additional URL passing structure for the info.
// If the [URL] is empty, link represents non-linkable simple text element.
// And, if title is empty, link represents empty line.
type Link struct {
	// Title is the main domain of [Link] structure.
	Title string `json:"title"`

	// The reference URL provider for [Title].
	// same approach of `<a href="http://">{Title}</a>`
	// but in go structure model.
	URL string `json:"url"`

	// Style is a font-style identifier of [Title] field.
	// Could be:
	//  - bold
	//  - italic
	//  - strong
	Style string `json:"style"`
}

// Takes byte array value of request body,
// and translates it to valid representation of [Info] map.
func TransformInfoBody(body []byte) map[string]interface{} {
	var data map[string]interface{}
	json.Unmarshal(body, &data)

	var info Info
	mapstructure.Decode(data, &info)

	return info.ToJson()
}

// Takes byte array value of request body,
// and translates it to valid representation of [Link] map.
func TransformLinkBody(body []byte) map[string]interface{} {
	var data map[string]interface{}
	json.Unmarshal(body, &data)

	var link Link
	mapstructure.Decode(data, &link)

	return link.ToJson()
}

// ToJson converts the [Info] structure to map value.
func (i *Info) ToJson() map[string]interface{} {
	b, _ := json.Marshal(&i)

	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)

	return m
}

// ToJson converts the [Link] structure to map value.
func (l *Link) ToJson() map[string]interface{} {
	b, _ := json.Marshal(&l)

	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)

	return m
}
