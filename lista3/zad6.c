#include <stdlib.h>

int main(void)
{
    int code=0;
    for(int i=0; i<16; i++)
    {
        for(int j=0; j<16; j++)
        {
            code = i * 16 + j;
            printf("\x1b[38;5;%dmHello, World!  ",code);
            printf("\x1b[0m");
        }
    }
    return 0;
}