//
// Copyright 2022-present theiskaa. All rights reserved.
// Use of this source code is governed by Apache-2.0 license
// that can be found in the LICENSE file.
//

package pkg

import (
	"fmt"
	"time"
)

// Now is a date generator for [Post] model of posts endpoint.
// Generated date would be something like:
//  > October 24 | 2022
func Now() string {
	t := time.Now()
	return fmt.Sprintf("%v %v | %v", t.Month().String(), t.Day(), t.Year())
}
