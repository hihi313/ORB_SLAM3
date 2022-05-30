#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>

using namespace cv;
using namespace std;

// OpenCV port of 'LAPV' algorithm (Pech2000)
double varianceOfLaplacian(const Mat& src, Mat *lap_result = NULL)
{
    Mat lap;
    Laplacian(src, lap, CV_64F);
    if(lap_result != NULL)
        *lap_result = lap;

    Scalar mu, sigma;
    meanStdDev(lap, mu, sigma);

    double focusMeasure = sigma.val[0]*sigma.val[0];
    return focusMeasure;
}

int main(int argc, char** argv)
{
    setbuf(stdout, NULL);

    // Kernel size
    Size kernel = Size(9, 9);

    Mat image;
    image = imread("../datasets/mav0/cam0/data/1403638130995097088.png", IMREAD_GRAYSCALE);
    // imshow("image", image);

    // Blur
    Mat blur;
    cv::blur(image, blur, kernel);
    // imshow("blur", blur);

    // Gaussian blur
    Mat gaussian;
    GaussianBlur(image, gaussian, kernel, 0); // both sigma are 0 == compute by kernel size
    // imshow("Gaussian", gaussian);

    // Median blur
    Mat median;
    medianBlur(image, median, kernel.height);
    // imshow("Median", median);

    vector<Mat> imgs;
    imgs.push_back(image);
    imgs.push_back(blur);
    imgs.push_back(gaussian);
    imgs.push_back(median);
    for(int i = 0; i < imgs.size(); i++)
    {
        // Variance of Laplacian
        printf("Focusness image[%d]: %f\n", i, varianceOfLaplacian(imgs[i]));
    }



    waitKey(0);
    return 0;
}