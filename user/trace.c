#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
    if (argc < 3)
    {
        printf("useage:trace mask command [command-args]\n");
        exit(0);
    }
    //todo:ignore the check of command-argument
    int mask = atoi(argv[1]);
    if (trace(mask) < 0)
    {
        printf("trace error\n");
        exit(0);
    }
    if (exec(argv[2], argv + 2) < 0)
    {
        printf("exec error\n");
        exit(0);
    }
    exit(0);
}
