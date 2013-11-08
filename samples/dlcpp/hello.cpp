//
//  hello.cpp  --  Say "Hello, world!"
//

#include "hello.h"

#include <iostream>

void hello_init(void)
{
    std::cout << "hello loaded" << '\n';
}

void hello_fini(void)
{
    std::cout << "hello before unload" << '\n';
}


void hello( void)
{
    std::cout << "Hello, world!" << '\n';
}

