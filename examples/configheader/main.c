/*
 *  main.c  --  Just show the programs parameter
 */

#include <stdio.h>

#include "config.h"

#define DATAFILE DIR_MYPROJ "/specialdata.db"

int main( int argc, char **argv)
{
    printf( "Datafile is `%s'.\n", DATAFILE);
    return 0;
}

