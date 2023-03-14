#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>

int main(int argc, char *argv[])
{
	double **a,**res;
	int i,j,k,N=2000;
	struct timeval start, stop;
	double start_ms, stop_ms;
	
	a = (double **)malloc(N * sizeof(double *));
	for (i=0; i<N; i++)
		a[i] = (double *)malloc(N * sizeof(double *));

	res = (double **)malloc(N * sizeof(double *));
	for (i=0; i<N; i++)
		res[i] = (double *)malloc(N * sizeof(double));
	
	gettimeofday(&start, NULL);

	for (i=0; i<N; i++){
		for(j=0; j<N; j++){
			res[i][j] = 0;
			for (k=0; k<N; k++)
				res[i][j] += a[i][k] * a[k][j];		
				//res[i][j] += a[i][k] * a[j][k];
		}
	}

	gettimeofday(&stop, NULL);
	start_ms = (double)start.tv_sec*1000000.0 + (double)start.tv_usec;
	stop_ms = (double)stop.tv_sec*1000000.0 + (double)stop.tv_usec;

	printf("Total time elapsed: %lf s\n", (stop_ms - start_ms)*1e-6);
}
