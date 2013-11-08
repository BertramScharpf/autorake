//
//  hello.h  --  Say "Hello, world!"
//

#ifndef __HELLO_H__
#define __HELLO_H__


#ifdef __cplusplus
extern "C" {
#endif

extern void __attribute__ ((constructor)) hello_init( void);
extern void __attribute__ ((destructor))  hello_fini( void);

extern void hello( void);

#ifdef __cplusplus
}
#endif


#endif

