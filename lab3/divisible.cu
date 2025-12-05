// Please compile with: nvcc -arch=sm_89 -o divisible divisible.cu

#include <cuda_runtime.h>
#include <stdio.h>
#include <stdlib.h>


__global__ void divisibility(char* device, int x, int y) {
  int id = blockIdx.x * blockDim.x + threadIdx.x;
  int total = gridDim.x * blockDim.x;

  for (int i = id + 2; i <= y; i += total) {
    if (i % x == 0) {
      device[i] = 1;
    }
  }
}

int main(int argc, char* argv[]) {
  int x = atoi(argv[1]);
  int y = atoi(argv[2]);
  int type = atoi(argv[3]);

  char* host = (char*)calloc(y + 1, sizeof(char));

  if (type == 1) {
    char* device;
    int threads = 256;
    int numBlocks = (y + threads - 1) / threads;

    cudaMalloc((void**)&device, (y + 1) * sizeof(char));
    cudaMemset(device, 0, (y + 1) * sizeof(char));

    if (numBlocks * threads > 5000) {
      numBlocks = 5000 / threads;
      if (numBlocks == 0) {
        numBlocks = 1;
        threads = (y < 5000) ? y : 5000;
      }
    }

    divisibility<<<numBlocks, threads>>>(device, x, y);

    cudaDeviceSynchronize();
    cudaMemcpy(host, device, (y + 1) * sizeof(char),
               cudaMemcpyDeviceToHost);

    int count = 0;
    for (int i = 0; i <= y; i++) {
      if (host[i] == 1) {
        count++;
      }
    }

    printf("There are %d numbers divisible by %d in the range [2, %d].\n",
           count, x, y);
    printf("Number of blocks used is %d\n", numBlocks);
    printf("Number of threads per block is %d\n", threads);

    cudaFree(device);

  } else {
    for (int i = 2; i <= y; i++) {
      if (i % x == 0) {
        host[i] = 1;
      }
    }

    int count = 0;
    for (int i = 0; i <= y; i++) {
      if (host[i] == 1) {
        count++;
      }
    }

    printf("There are %d numbers divisible by %d in the range [2, %d].\n",
           count, x, y);
  }

  free(host);

  return 0;
}
