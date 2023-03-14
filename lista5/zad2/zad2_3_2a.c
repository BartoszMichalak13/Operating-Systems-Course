#include <stdio.h>
#include <signal.h>
#include <unistd.h>
int send_signal(int pid)
{
	//printf("%d\n",pid);
	int ret;
	for(int i=0;i<100;++i)
	{
		ret = kill(pid, 34);
		printf("ret: %d \n",ret);
	}
}
int main(int argc, char *argv[])
{
	int pid;
	//printf("%s\n", argv[1]);
	sscanf(argv[1], "%d", &pid);
	//printf("%d\n",pid);
	send_signal(pid);
}
