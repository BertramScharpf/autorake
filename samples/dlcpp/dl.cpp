//
//  dl.cpp  --  Dynamic libraries
//

#include "dl.h"

#include <iostream>


Dl::Dl( const char *path, int mode) :
    H( dlopen( path, mode))
{
    if (!H)
        throw Error();
}

void *Dl::sym( const char *sym) const
{
    void *r = dlsym( H, sym);
    if (!r)
        throw Error();
    return r;
}


