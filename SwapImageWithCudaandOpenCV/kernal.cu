//opencv_cuda.cu:ʹ���Զ��庯����ʵ��cuda�汾ͼƬ��ת
//authored by alpc40,Bizat
//version��visual studio 2019\cuda toolkit 11.0\openCV 4.4.0
#include "opencv2/opencv.hpp"
#include "cuda_runtime.h"
#include "device_launch_parameters.h"
#include <stdio.h>

#include<iostream>
using namespace std;
using namespace cv;
#ifdef _DEBUG
#pragma comment ( lib,"opencv_core440d.lib")
#pragma comment ( lib,"opencv_highgui440d.lib")
#pragma comment ( lib,"opencv_calib3d440d.lib")
#pragma comment ( lib,"opencv_imgcodecs440d.lib")
#pragma comment ( lib,"opencv_imgproc440d.lib")
#pragma comment ( lib,"opencv_cudaimgproc440d.lib")
#pragma comment ( lib,"opencv_cudaarithm440d.lib")
#pragma comment ( lib,"cudart.lib")
#else
#pragma comment ( lib,"opencv_core320.lib")
#pragma comment ( lib,"opencv_highgui320.lib")
#pragma comment ( lib,"opencv_calib3d320.lib")
#pragma comment ( lib,"opencv_imgcodecs320.lib")
#pragma comment ( lib,"opencv_imgproc320.lib")
#pragma comment ( lib,"opencv_cudaimgproc320.lib")
#pragma comment ( lib,"opencv_cudaarithm320.lib")
#pragma comment ( lib,"cudart.lib")
#endif
//��������
#define CHECK_ERROR(call){\
    const cudaError_t err = call;\
    if (err != cudaSuccess)\
    {\
        printf("Error:%s,%d,",__FILE__,__LINE__);\
        printf("code:%d,reason:%s\n",err,cudaGetErrorString(err));\
        exit(1);\
    }\
}
//�ں˺�����ʵ�����·�ת
__global__ void swap_image_kernel(cuda::PtrStepSz<uchar3> cu_src, cuda::PtrStepSz<uchar3> cu_dst, int h, int w)
{
    //����ķ������ο�ǰ������
    unsigned int x = blockDim.x * blockIdx.x + threadIdx.x;
    unsigned int y = blockDim.y * blockIdx.y + threadIdx.y;
    //ΪɶҪ�������ƣ��ο�ǰ������
    if (x < cu_src.cols && y < cu_src.rows)
    {
        //Ϊ�β���h-y-1,������h-y���Լ�˼��Ŷ
        cu_dst(y, x) = cu_src(h - y - 1, x);
    }
}
//���ú�������Ҫ����block��grid�Ĺ�ϵ
void swap_image(cuda::GpuMat src, cuda::GpuMat dst, int h, int w)
{
    assert(src.cols == w && src.rows == h);
    int uint = 32;
    //�ο�ǰ�����ĵ�block��grid�ļ��㷽����ע�ⲻҪ����GPU����
    dim3 block(uint, uint);
    dim3 grid((w + block.x - 1) / block.x, (h + block.y - 1) / block.y);
    printf("grid = %4d %4d %4d\n", grid.x, grid.y, grid.z);
    printf("block= %4d %4d %4d\n", block.x, block.y, block.z);
    swap_image_kernel << <grid, block >> > (src, dst, h, w);
    //ͬ��һ�£���Ϊ���������ܴܺ�
    CHECK_ERROR(cudaDeviceSynchronize());
}
int main(int argc, char** argv)
{
    Mat src, dst;
    cuda::GpuMat cu_src, cu_dst;
    int h, w;
    //����argv[1]����ͼƬ���ݣ�BGR��ʽ������
    src = imread("C:\\Users\\Bizat\\Pictures\\��Ѿͷ.jpg");
    //����Ƿ���ȷ����
    if (src.data == NULL)
    {
        cout << "Read image error" << endl;
        return -1;
    }
    h = src.rows; w = src.cols;
    cout << "ͼƬ�ߣ�" << h << ",ͼƬ��" << w << endl;
    //�ϴ�CPUͼ�����ݵ�GPU����cudaMalloc��cudaMemcpy����Ŷ����ʵupload���������ôд��
    cu_src.upload(src);
    //����GPU�ռ䣬Ҳ���Ե����������룬����������Ҫ���룬Ҫ��Ȼ�ں˺����ᱬ��Ŷ
    cu_dst = cuda::GpuMat(h, w, CV_8UC3, Scalar(0, 0, 0));
    //����CPU�ռ�
    dst = Mat(h, w, CV_8UC3, Scalar(0, 0, 0));
    //���ú���swap_image,�ɸú��������ں˺�����������η����������׳���
    //��Ȼ��Ҳ����ֱ������������ں˺���������̫�����������
    swap_image(cu_src, cu_dst, h, w);
    //����GPU���ݵ�CPU����upload()��Ӧ
    cu_dst.download(dst);
    //��ʾcpuͼ�������װ��openCV������openGL,�ǿ���ֱ����ʾGpuMat
    imshow("dst", dst);
    //�ȴ�����
    waitKey();
    //дͼƬ���ļ�
    if (argc == 3)
        imwrite("C:\\Users\\Bizat\\Pictures\\��Ѿͷ2.jpg", dst);
    return 0;
}