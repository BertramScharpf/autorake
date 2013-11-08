//
//  dl.h  --  Dynamic libraries
//

#ifndef __DL_H
#define __DL_H

#include <dlfcn.h>

class Dl {
    void *H;

public:
    class Error {
        const char *M;
    public:
        Error( void) : M( dlerror()) {}

        operator const char * ( void) const { return M; }
    };

public:
    Dl( const char *path, int mode = RTLD_LAZY);
    ~Dl( void) { dlclose( H);}

    void *sym( const char *sym) const;

private:
    Dl( const Dl &);
    Dl &operator = ( const Dl &);
};


#endif

