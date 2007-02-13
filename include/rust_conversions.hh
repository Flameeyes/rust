/* Copyright (c) 2005-2007 Diego Pettenò <flameeyes@gmail.com>
 * 
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software,
 * and to permit persons to whom the Software is furnished to do so,
 * subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
 * BE LIABLE
 * FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
 * CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#ifndef __RUST_CONVERSIONS__
#define __RUST_CONVERSIONS__

#include <stdint.h>
#include <ruby.h>

static inline uint64_t ruby2uint(VALUE rval) {
  return NUM2UINT(rval);
}

static inline int64_t ruby2int(VALUE rval) {
  return NUM2INT(rval);
}

/* Standard conversions for stdint-provided types */
#define ruby2uint64_t ruby2uint
#define ruby2uint32_t ruby2uint
#define ruby2uint16_t ruby2uint
#define ruby2uint8_t  ruby2uint

#define ruby2int64_t  ruby2int
#define ruby2int32_t  ruby2int
#define ruby2int16_t  ruby2int
#define ruby2int8_t   ruby2int

#endif
