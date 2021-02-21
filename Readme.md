# Step by step - CUDA build process

 This is CUDA vector addition sample that can be used to learn about CUDA build process.

 It was created after experiencing bug in glibc-2.17-323.el7_9 that lead to nvcc compilation failures (https://bugzilla.redhat.com/show_bug.cgi?id=1925204).
 
 Good references about CUDA build process are
 * https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/index.html
 * https://on-demand.gputechconf.com/gtc/2013/webinar/cuda-toolkit-as-build-tool.pdf

## Usage

 You can start the docker container with `make run_nvidia`. 
 Then, you can call `make all` to compile kernel.cu file. 
 All intermediate compilation files are preserved. 

 Or, you can run the compilation step by step by executing make targets `step1` `step2` ... and analyze the output of every step. 

 Inspect the Makefile for more details. 

