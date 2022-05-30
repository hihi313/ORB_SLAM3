#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>

// OpenCV port of 'LAPM' algorithm (Nayar89)
double modifiedLaplacian(const cv::Mat& src)
{
    cv::Mat M = (cv::Mat_<double>(3, 1) << -1, 2, -1);
    cv::Mat G = cv::getGaussianKernel(3, -1, CV_64F);

    cv::Mat Lx;
    cv::sepFilter2D(src, Lx, CV_64F, M, G);

    cv::Mat Ly;
    cv::sepFilter2D(src, Ly, CV_64F, G, M);

    cv::Mat FM = cv::abs(Lx) + cv::abs(Ly);

    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

// OpenCV port of 'LAPV' algorithm (Pech2000)
double varianceOfLaplacian(const cv::Mat& src)
{
    cv::Mat lap;
    cv::Laplacian(src, lap, CV_64F);

    cv::Scalar mu, sigma;
    cv::meanStdDev(lap, mu, sigma);

    double focusMeasure = sigma.val[0]*sigma.val[0];
    return focusMeasure;
}

// OpenCV port of 'TENG' algorithm (Krotkov86)
double tenengrad(const cv::Mat& src, int ksize)
{
    cv::Mat Gx, Gy;
    cv::Sobel(src, Gx, CV_64F, 1, 0, ksize);
    cv::Sobel(src, Gy, CV_64F, 0, 1, ksize);

    cv::Mat FM = Gx.mul(Gx) + Gy.mul(Gy);

    double focusMeasure = cv::mean(FM).val[0];
    return focusMeasure;
}

// OpenCV port of 'GLVN' algorithm (Santos97)
double normalizedGraylevelVariance(const cv::Mat& src)
{
    cv::Scalar mu, sigma;
    cv::meanStdDev(src, mu, sigma);

    double focusMeasure = (sigma.val[0]*sigma.val[0]) / mu.val[0];
    return focusMeasure;
}

int main(int argc, char** argv)
{
    setbuf(stdout, NULL);

    cv::Mat image;
    image = cv::imread("Lena.png", cv::IMREAD_COLOR);

    // Clone image
    cv::Mat clone = image.clone();
    
    double focusness_LAPM = modifiedLaplacian(clone);
    double focusness_LAPV = varianceOfLaplacian(clone);
    double focusness_TENG = tenengrad(clone, 3);
    double focusness_GLVN = normalizedGraylevelVariance(clone);
    printf("Focusness LAPM: %f\n", focusness_LAPM);
    printf("Focusness LAPV: %f\n", focusness_LAPV);
    printf("Focusness TENG: %f\n", focusness_TENG);
    printf("Focusness GLVN: %f\n", focusness_GLVN);

    // Show image
    cv::imshow("image", image);
    cv::imshow("clone", clone);
    cv::waitKey(0);
    return 0;
}