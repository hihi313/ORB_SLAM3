#include <opencv2/highgui.hpp>
#include <iostream>

int main(int argc, char** argv)
{
    cv::Mat image;
    image = cv::imread("Lena.png", cv::IMREAD_COLOR);
    cv::namedWindow("namba image", cv::WINDOW_AUTOSIZE);
    cv::imshow("namba image", image);
    cv::waitKey(0);
    return 0;
}