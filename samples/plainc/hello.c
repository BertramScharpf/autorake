/*
 *  hello.c  --  Say hello to the world.
 */

#ifdef HAVE_HEADER_STDIO_H
    #include <stdio.h>
    #define SAY_IT
#endif

int main( int argc, char ** argv)
{
#ifdef SAY_IT
    printf( "Hello, world!\n");
#endif
#ifdef FEATURE_NOW
    printf( "Now is the time.\n");
#endif
    return 0;
}

