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
// Holds pure html page data, and profile picture.
type Info struct {
	Picture  string `json:"picture"`
	Data     string `json:"data"`
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

// ToJson converts the [Info] structure to map value.
func (i *Info) ToJson() map[string]interface{} {
	b, _ := json.Marshal(&i)

	var m map[string]interface{}
	_ = json.Unmarshal(b, &m)

	return m
}
