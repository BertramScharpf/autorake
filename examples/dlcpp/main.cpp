//
//  main.cpp  --  Load a dynamic library and call an exported function
//

#include "dl.h"
#include <iostream>

int main( int argc, const char **argv)
{
    try {
        Dl dl( "./hello.so");

        void (*f)( void) = (void (*)( void)) dl.sym( "hello");

        (*f)();
        return 0;
    }
    catch (Dl::Error &e) {
        std::cerr << (const char *) e << "\n";
        return 1;
    }
}

