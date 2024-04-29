#include "kernel/types.h"
#include "user/user.h"

int main()
{
    int pfd[2];
    if ((pipe(pfd)) == -1)
    {
        printf("can`t create pipe now\n");
        exit(0);
    }
    int ret = fork();
    if (ret > 0)
    {
        char byte = 'o';
        close(pfd[1]);
        write(pfd[0], &byte, 1);
        read(pfd[0], &byte, 1);
        printf("%d: received pong\n", getpid());
        close(pfd[0]);
    }
    else if (ret == 0)
    {
        char byte;
        close(pfd[0]);
        read(pfd[1], &byte, 1);
        printf("%d: received ping\n", getpid());
        write(pfd[1], &byte, 1);
        close(pfd[1]);
    }
    else
    {
        printf("fork error here\n");
    }
    exit(0);
}