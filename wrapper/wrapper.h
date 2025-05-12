/* libSupport - Powerful app modification library
 * Copyright (c) 2022-2025 Rednick16 (Red16)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE, QUIET ENJOYMENT OR NON-INFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#ifndef wrapper_h
#define wrapper_h

#include <unistd.h>
#include <objc/runtime.h>
#include <objc/message.h>

#ifdef __cplusplus
    #define LS_EXTERN extern "C"
#else
    #define LS_EXTERN extern
#endif

/* common storage attributes */
#define LS_STATIC static
#define LS_FORCE_INLINE inline __attribute__((__always_inline__))
#define LS_NO_INLINE __attribute__((__noinline__))
#define LS_IGNORE __attribute__((__unused__))
#define LS_EXPORT __attribute__((__visibility__("default"))) LS_EXTERN
#define LS_PRIVATE __attribute__((__visibility__("hidden"))) LS_EXTERN

/* utility macros */
#define LS_CAST(type, value) ((type)(value))
#define LS_ALIGNPTR(p, align) ((void *)(((uintptr_t)(p) + (align - 1)) & ~(align - 1)))
#define LS_ARRAYSIZE(arr) (sizeof(arr) / sizeof((arr)[0]))
#define LS_UNUSED(var) ((void)(var))

#define LS_STRINGIFY(x) #x
#define LS_TOSTRING(x) LS_STRINGIFY(x)

#define LS_CONCAT_IMPL(_A, _B) _A##_B
#define LS_CONCAT(_A, _B) LS_CONCAT_IMPL(_A, _B)

/* branch prediction gints, mainly used for error checking. */
#define LS_LIKELY(x)   (__builtin_expect(((x) != 0), 1))
#define LS_UNLIKELY(x) (__builtin_expect(((x) != 0), 0))
#define LS_CALLER_ADDRESS() __builtin_extract_return_addr(__builtin_return_address(0))

/* custom constructor */
#define LS_CTOR 												\
	__attribute__((__constructor__)) 							\
	LS_STATIC void LS_CONCAT(LS_InitFunc_, __COUNTER__)(void)

#define LS_CTOR_(priority) 										\
	__attribute__((__constructor__(priority))) 					\
	LS_STATIC void LS_CONCAT(LS_InitFunc_, __COUNTER__)(void)

/* libSupport deprecation macro */
#define LS_DEPRECATED(symbol, message)					 		\
	symbol __attribute__((__deprecated__(message)))

/* libSupport memory protection flags */
#define LSM_PROT_NONE 	0x00
#define LSM_PROT_READ 	0x01 
#define LSM_PROT_WRITE 	0x02
#define LSM_PROT_EXEC 	0x04

/* maximum allowable protections we can set
 * for some reason, this actually works in our JIT environment (x_x).
 * maybe Apple changed something with JIT in iOS 15+ ?
 */
#define LSM_PROT_ALL 	(LS_PROT_READ|LS_PROT_WRITE|LS_PROT_EXEC)

/* libSupport memory operation return codes */
#define LSM_FAILURE 			0
#define LSM_SUCCESS 			1
#define LSM_INVALID_BUFFER 		2
#define LSM_MAP_FAILURE 		3
#define LSM_INVALID_ADDRESS 	4
#define LSM_INVALID_LENGTH 		5
#define LSM_PROTECTION_FAILURE 	6
#define LSM_INVALID_ARGUMENTS 	69420 /* :p */

/* debugging stuff :) */
#ifndef LS_DEBUG
#define LS_DEBUG 0
#endif

#if LS_DEBUG
LS_EXPORT void _support_logimpl(const char*, ...);
#define LS_LOG(format, ...) _support_logimpl(format, ##__VA_ARGS__)

LS_EXPORT void _support_assertimpl(const char*, const char*, int, const char*, ...);
#define LS_ASSERT(expr, ...) 															\
	((LS_LIKELY(expr)) 																	\
		? (LS_UNUSED(0)) 																\
		: _support_assertimpl(LS_TOSTRING(expr), __FILE__, __LINE__, ##__VA_ARGS__))
#else
#define LS_LOG(...) LS_UNUSED(0)
#define LS_ASSERT(...) LS_UNUSED(0)
#endif

#endif //wrapper_h