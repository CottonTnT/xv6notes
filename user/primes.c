#include "kernel/types.h"
#include "user/user.h"

int lhs[2];
int rhs[2];
int has_right = 0;

void create_right_process(int prime)
{
    int ret = fork();
    if (ret < 0)
    {
        printf("can`t fork now\n");
        exit(0);
    }
    else if (ret > 0)
        return;
    int has_right = 0;
    lhs[0] = rhs[0];
    lhs[1] = rhs[1];
    close(lhs[1]);
    printf("prime %d\n", prime);
    int num;
    while (read(lhs[0], &num, sizeof(int)))
    {
        if (num % prime == 0)
            continue;
        if (!has_right)
        {
            has_right = 1;
            if (pipe(rhs) < 0)
            {
                printf("can`t create pipe now\n");
                close(lhs[0]);
                exit(0);
            }
            create_right_process(num);
            close(rhs[0]);
        }
        write(rhs[1], &num, sizeof(int));
    }
    close(lhs[0]);
    if (has_right)
    {
        close(rhs[1]);
        wait(0);
    }
    exit(0);
}
int main()
{
    if (pipe(rhs) == -1)
    {
        printf("cant`t create pipe now\n");
        exit(0);
    }
    create_right_process(2);
    close(rhs[0]);
    for (int i = 3; i < 36; i++)
    {
        write(rhs[1], &i, sizeof(int));
    }
    close(rhs[1]);
    wait(0);
    exit(0);
}