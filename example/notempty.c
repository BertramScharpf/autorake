/*
 *  notempty.c  --  String#notempty? analogous to Numeric#nonzero?
 */


#include "notempty.h"

#include <ruby.h>
#ifdef HAVE_HEADER_ST_H
  #include <st.h>
#else
  /* we don't use it here anyway ... */
#endif


/*
 *  call-seq:
 *     str.notempty?   => nil or self
 *
 *  Returns <i>self</i> if and only if <i>str</i> is not empty,
 *  <code>nil</code> otherwise.
 *
 *     "hello".notempty?   #=> "hello"
 *     "".notempty?        #=> nil
 */

static VALUE rb_str_notempty( VALUE str)
{
#if 0
    /* Ruby Coding style */
    if (RSTRING_LEN(str) == 0)
        return Qnil;
    return str;
#else
    return RSTRING_LEN( str) ? str : Qnil;
#endif
}



void Init_notempty( void)
{
    rb_define_method( rb_cString, "notempty?", rb_str_notempty, 0);
}

