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
	Content     string `json:"content"`
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

// ToJson converts the [Post] structure to map value.
func (p *Post) ToJson() map[string]interface{} {
	res, _ := json.Marshal(p)

	m := make(map[string]interface{})
	json.Unmarshal(res, &m)

	return m
}
