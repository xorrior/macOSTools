#include <stdio.h>
#include <string.h>
#include <stdlib.h>

__attribute__ ((constructor))
static void initializer()
{
    FILE *fp;
    fp = fopen("/tmp/test.txt", "w");
    fprintf(fp, "I'm a constructor\n");
    fclose(fp);
    return;
}

