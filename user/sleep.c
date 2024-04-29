#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char* argv[])
{
    if (argc >= 3) {
        printf("error ,Usage:sleep number\n");
        exit(0);
    }
    uint number = atoi(argv[1]);
    sleep(number);
    exit(0);
}