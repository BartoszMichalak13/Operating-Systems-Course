#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <emmintrin.h>


#define N 2000
#define CLS 64
double res[N][N] __attribute__ ((aligned (64)));
double mul1[N][N] __attribute__ ((aligned (64)));
double mul2[N][N] __attribute__ ((aligned (64)));
#define SM (CLS / sizeof (double))

int main(int argc, char *argv[])
{

	int i, i2, j, j2, k, k2;
	double *restrict rres;
	double *restrict rmul1;
	double *restrict rmul2;
	
	
	
	double **mul1,**res;
	//int i,j,k=2000;
	struct timeval start, stop;
	double start_ms, stop_ms;
	
	mul1 = (double **)malloc(N * sizeof(double *));
	for (i=0; i<N; i++)
		mul1[i] = (double *)malloc(N * sizeof(double *));

	res = (double **)malloc(N * sizeof(double *));
	for (i=0; i<N; i++)
		res[i] = (double *)malloc(N * sizeof(double));
	
	gettimeofday(&start, NULL);
	

	double **tmp;
	tmp = (double **)malloc(N * sizeof(double *));
	for (i=0; i<N; i++)
		tmp[i] = (double *)malloc(N * sizeof(double));




	// ... Initialize mul1 and mul2

	for (i = 0; i < N; i += SM)
		for (j = 0; j < N; j += SM)
			for (k = 0; k < N; k += SM)
				for (i2 = 0, rres = &res[i][j], rmul1 = &mul1[i][k]; i2 < SM; ++i2, rres += N, rmul1 += N)
				{
					_mm_prefetch (&rmul1[8], _MM_HINT_NTA);
					for (k2 = 0, rmul2 = &mul2[k][j]; k2 < SM; ++k2, rmul2 += N)
					{
						__m128d m1d = _mm_load_sd (&rmul1[k2]);
						m1d = _mm_unpacklo_pd (m1d, m1d);
						for (j2 = 0; j2 < SM; j2 += 2)
						{
							__m128d m2 = _mm_load_pd (&rmul2[j2]);
							__m128d r2 = _mm_load_pd (&rres[j2]);
							_mm_store_pd (&rres[j2],
							_mm_add_pd (_mm_mul_pd (m2, m1d), r2));
						}
					}
				}
	// ... use res matrix

	for (i=0; i<N; i++){
		for (j=0; j<N; j++){
			tmp[i][j]=mul1[j][i];
			//printf("T2\n");
		}
	}
	for (i=0; i<N; i++){
		for(j=0; j<N; j++){
			res[i][j] = 0;
			for (k=0; k<N; k++)
				//res[i][j] += mul1[i][k] * a[k][j];		
				res[i][j] += mul1[i][k] * tmp[j][k];
		}
	}

	gettimeofday(&stop, NULL);
	start_ms = (double)start.tv_sec*1000000.0 + (double)start.tv_usec;
	stop_ms = (double)stop.tv_sec*1000000.0 + (double)stop.tv_usec;

	printf("Total time elapsed: %lf s\n", (stop_ms - start_ms)*1e-6);
	return 0;
}
