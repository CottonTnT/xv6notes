#include "kernel/types.h"
#include "kernel/stat.h"
#include "kernel/fs.h"
#include "kernel/fcntl.h"
#include "user/user.h"

char* fmtname(char* path)
{
    static char buf[DIRSIZ + 1];
    char* p;

    // Find first character after last slash.
    for (p = path + strlen(path); p >= path && *p != '/'; p--)
        ;
    p++;

    // Return blank-padded name.
    if (strlen(p) >= DIRSIZ)
        return p;
    memmove(buf, p, strlen(p));
    memset(buf + strlen(p), '\0', DIRSIZ - strlen(p));
    return buf;
}

void find(char* path, char* target)
{
    int fd = open(path, O_RDONLY);
    if (fd < 0)
    {
        fprintf(2, "can`t open %s\n", path);
        exit(0);
    }
    struct stat st;
    if (fstat(fd, &st) < 0)
    {
        close(fd);
        fprintf(2, "can`t stat %s\n", path);
        exit(0);
    }
    switch (st.type)
    {
        case T_DIR: {
            char buf[512];
            if (strlen(path) + 1 + DIRSIZ + 1 > sizeof buf)
            {
                printf("find: path too long\n");
                break;
            }
            strcpy(buf, path);
            char* p = buf + strlen(path);
            *p = '/';
            p++;
            struct dirent de;
            while (read(fd, &de, sizeof de) == sizeof de)
            {
                if (de.inum == 0)
                    continue;
                if (!strcmp(de.name, "."))
                    continue;
                if (!strcmp(de.name, ".."))
                    continue;
                memmove(p, de.name, DIRSIZ);
                p[DIRSIZ] = 0;
                // printf("%s\n", buf);
                find(buf, target);
            }
            break;
        }

        case T_FILE: {
            // printf("%s %s\n", fmtname(path), target);
            if (!strcmp(fmtname(path), target))
            {
                printf("%s\n", path);
            }
            break;
        }
    }
    close(fd);
}
int main(int argc, char* argv[])
{
    if (argc > 3)
    {
        fprintf(2, "useage:find from_path filename");
        exit(0);
    }
    char* path = argv[1];
    int fd = open(path, O_RDONLY);
    if (fd < 0)
    {
        fprintf(2, "can`t open %s\n", path);
        exit(0);
    }
    struct stat st;
    if (fstat(fd, &st) < 0)
    {
        fprintf(2, "can`t stat %s\n", path);
        close(fd);
        exit(0);
    }
    if (st.type == T_FILE)
    {
        fprintf(2, "%s is not directory\n", path);
        close(fd);
        exit(0);
    }
    find(path, argv[2]);
    exit(0);
}