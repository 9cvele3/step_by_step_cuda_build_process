NVCCFLAGS:=-c --verbose --keep #-std=c++11 -Xcompiler -std=c++11

%.o: %.cu
	/usr/local/cuda/bin/nvcc $(NVCCFLAGS) $< $@

all: kernel.o

run-nvidia:
	docker run --rm -it -v`pwd`:/app nvidia/cuda:10.0-devel-centos7 /bin/bash 


clean:
	-rm *.cpp1.ii
	-rm *.cpp4.ii
	-rm *.cudafe1.c
	-rm *.cudafe1.cpp
	-rm *.cudafe1.gpu
	-rm *.cudafe1.stub.c
	-rm *.fatbin
	-rm *.fatbin.c
	-rm *.module_id
	-rm *.ptx
	-rm *.cubin
	-rm *.o

help:
	@echo step1: gcc
	@echo step2: cicc
	@echo step3: ptxas
	@echo step4: fatbinary
	@echo step5: gcc
	@echo step6: cudafe++
	@echo step7: gcc

step1:
	gcc -D__CUDA_ARCH__=300 -E -x c++  -DCUDA_DOUBLE_MATH_FUNCTIONS -D__CUDACC__ -D__NVCC__  "-I/usr/local/cuda/bin/../targets/x86_64-linux/include"    -D__CUDACC_VER_MAJOR__=10 -D__CUDACC_VER_MINOR__=0 -D__CUDACC_VER_BUILD__=130 -include "cuda_runtime.h" -m64 "kernel.cu" > "kernel.cpp1.ii" 

step2: 
	/usr/local/cuda/nvvm/bin/cicc --gnu_version=40805 --allow_managed   -arch compute_30 -m64 -ftz=0 -prec_div=1 -prec_sqrt=1 -fmad=1 --include_file_name "kernel.fatbin.c" -tused -nvvmir-library "/usr/local/cuda/bin/../nvvm/libdevice/libdevice.10.bc" --gen_module_id_file --module_id_file_name "kernel.module_id" --orig_src_file_name "kernel.cu" --gen_c_file_name "kernel.cudafe1.c" --stub_file_name "kernel.cudafe1.stub.c" --gen_device_file_name "kernel.cudafe1.gpu"  "kernel.cpp1.ii" -o "kernel.ptx"

step3:
	/usr/local/cuda/bin/ptxas -arch=sm_30 -m64  "kernel.ptx"  -o "kernel.sm_30.cubin" 

step4:
	PATH=/usr/local/cuda/bin:${PATH} /usr/local/cuda/bin/fatbinary --create="kernel.fatbin" -64 "--image=profile=sm_30,file=kernel.sm_30.cubin" "--image=profile=compute_30,file=kernel.ptx" --embedded-fatbin="kernel.fatbin.c" --cuda

step5:
	gcc -E -x c++ -D__CUDACC__ -D__NVCC__  "-I/usr/local/cuda/bin/../targets/x86_64-linux/include"    -D__CUDACC_VER_MAJOR__=10 -D__CUDACC_VER_MINOR__=0 -D__CUDACC_VER_BUILD__=130 -include "cuda_runtime.h" -m64 "kernel.cu" > "kernel.cpp4.ii" 

step6:
	cudafe++ --gnu_version=40805 --allow_managed  --m64 --parse_templates --gen_c_file_name "kernel.cudafe1.cpp" --stub_file_name "kernel.cudafe1.stub.c" --module_id_file_name "kernel.module_id" "kernel.cpp4.ii" 

hack:
	sed 's/nan\.0/0\.0/g' -i kernel.cudafe1.cpp

step7:
	gcc -D__CUDA_ARCH__=300 -c -x c++  -DCUDA_DOUBLE_MATH_FUNCTIONS "-I/usr/local/cuda/bin/../targets/x86_64-linux/include"   -m64 -o "kernel.o" "kernel.cudafe1.cpp" 
