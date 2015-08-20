/*
 *  hello.c  --  Say hello to the world.
 */

#ifdef HAVE_HEADER_STDIO_H
    #include <stdio.h>
    #define SAY_IT
#endif

#ifdef FEATURE_NOW
    #include <string.h>
#endif


#define CONFIGFILE WITH_SYSCONF "/myproj.cfg"
#define DATAFILE   WITH_MYPROJ "/somedata"


int main( int argc, char **argv)
{

#ifdef SAY_IT
    printf( "Hello, world!\n");
#endif

#ifdef FEATURE_NOW
    if (strcmp( WITH_FOO, "dummy") == 0)
        printf( "Now is the time.\n");
#endif

    printf( "Config file is: '%s'\n", CONFIGFILE);
    printf( "Data   file is: '%s'\n", DATAFILE);

    return 0;
}

