// OpenCVTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//

#include <opencv2/opencv.hpp>
using namespace cv;

int main()
{
	Mat img = imread("C:\\Users\\Bizat\\Pictures\\二丫头.jpg");    //引号内选一张自己计算机内的图片的路径
	imshow("二丫头", img);    //打开一个窗口，显示图片
	waitKey(0);    //在键盘敲入字符前程序处于等待状态
	destroyAllWindows();    //关闭所有窗口
	return 0;
}

// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   1. Use the Solution Explorer window to add/manage files
//   2. Use the Team Explorer window to connect to source control
//   3. Use the Output window to see build output and other messages
//   4. Use the Error List window to view errors
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
