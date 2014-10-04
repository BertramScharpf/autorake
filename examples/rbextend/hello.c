/*
 *  hello.c  --  Say "Hello, world!"
 */


#include "hello.h"

#if   defined( HAVE_HEADER_RUBY_H)
    #include <ruby.h>
#elif defined( HAVE_HEADER_RUBY_RUBY_H)
    #include <ruby/ruby.h>
#else
    #error "Ruby doesn't seem to be installed."
#endif


static ID id_puts;

static VALUE rb_obj_hello_bang( VALUE obj);


/*
 *  call-seq:
 *     obj.hello!   => nil
 *
 *  Prints "Hello, world!".
 *
 */

VALUE rb_obj_hello_bang( VALUE obj)
{
    return rb_funcall( obj, id_puts, 1, rb_str_new2( "Hello, world!"));
}



void Init_hello( void)
{
    rb_define_method( rb_cObject, "hello!", &rb_obj_hello_bang, 0);

    id_puts = rb_intern( "puts");
}

