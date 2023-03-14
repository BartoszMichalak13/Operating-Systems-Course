#include <stdio.h>
#include <signal.h>
#include <unistd.h>

struct sigaction siga;

void f(int sig)
{
	printf("Zlapalismy: %d\n", sig);
}

void the_caller(void(*f)(int sig))
{
	siga.sa_handler = f;
	for (int sig = 1; sig <= SIGRTMAX; ++sig)
	{
		if(sigaction(sig, &siga, NULL)==(-1))
			printf("Unable to catch: %d \n", sig);
	}
}

int main()
{
	the_caller(f);
	pause(); //wait for signal
	return 0;
}
