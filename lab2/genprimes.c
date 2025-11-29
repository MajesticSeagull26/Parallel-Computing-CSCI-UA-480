#include <math.h>
#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int isPrime(int x) {
  if (x == 2) return 1;
  if (x % 2 == 0) return 0;

  for (int i = 3; i * i <= x; i += 2) {
    if (x % i == 0) {
      return 0;
    }
  }
  return 1;
}

int compareInts(const void* a, const void* b) {
  int intA = *((int*)a);
  int intB = *((int*)b);
  if (intA < intB) return -1;
  if (intA > intB) return 1;
  return 0;
}

int main(int argc, char* argv[]) {
  double tstart = 0.0, tend = 0.0, ttaken;

  int M = atoi(argv[1]);
  int N = atoi(argv[2]);
  int t = atoi(argv[3]);

  int* primes = malloc((N - M + 1) * sizeof(int));
  int primeCount = 0;

  tstart = omp_get_wtime();
  omp_set_num_threads(t);

#pragma omp parallel
  {
    int* localPrimes = malloc((N - M + 1) * sizeof(int));
    int localCount = 0;

#pragma omp
    for (int x = M; x <= N; x++) {
      if (isPrime(x)) {
        localPrimes[localCount++] = x;
      }
    }

#pragma omp barrier

#pragma omp critical
    {
      for (int i = 0; i < localCount; i++) {
        primes[primeCount++] = localPrimes[i];
      }
    }

    free(localPrimes);
  }

  ttaken = omp_get_wtime() - tstart;

  qsort(primes, primeCount, sizeof(int), compareInts);

  char filename[50];
  sprintf(filename, "%d.txt", N);
  FILE* fp = fopen(filename, "w");

  for (int i = 0; i < primeCount; i++) {
    fprintf(fp, "%d\n", primes[i]);
  }
  fclose(fp);

  printf("The number of prime numbers found between %d and %d is %d.\n", M, N,
         primeCount);
  printf("Time taken for the main part: %.6f seconds\n", ttaken);

  free(primes);
  return 0;
}
