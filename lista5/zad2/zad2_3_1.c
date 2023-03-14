#include <stdio.h>
#include <signal.h>
#include <unistd.h>


int i=0;
void f(int sig)
{
	printf("Zlapalismy: %d\t %d\n", sig, i);
	i++;
}

void the_caller(void(*f)(int sig))
{
	
	//for (int sig = 1; sig <= SIGRTMAX; ++sig)
	//{
	//	if(sigaction(SIGHUP, &siga, NULL)==(-1))
	//		printf("Unable to catch: %d \n", sig);
	//}
}

int main()
{
	//printf("%d\n",SIGRTMIN);
	struct sigaction sa;
	sa.sa_handler = f;
	sigaction(SIGUSR1, &sa, NULL);
	//sigaction(SIGRTMIN, &sa, NULL);
	while(i<100)
	{
		//przy pauzie lapie +/- po jendym
		//i bez tez :O, najwyrazniije wolno dizala  f
		//pause();
		//sleep(5000);
	}
		///sigemptyset(&sa.sa_mask);
		//sa.sa_flags = SA_RESTART;
		if(sigaction(SIGHUP, &sa, NULL)==(-1))
			printf("Unable to catch: SIGHUP\n");
		if(sigaction(SIGUSR1, &sa, NULL)==(-1))
			printf("Unable to catch: SIGUSR1\n");
		//the_caller(f);
		//wait for signal
	
	return 0;
}
