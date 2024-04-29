#include "kernel/types.h"
#include "user/user.h"
#include <limits.h>

int main()
{
    printf("%l", ULLONG_MAX);
    exit(0);
}
