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
// Draw the PSF in spectrum domain
void calcPSF(Mat& outputImg, Size filterSize, int R)
{
    Mat h(filterSize, CV_32F, Scalar(0));
    Point point(filterSize.width / 2, filterSize.height / 2);
    circle(h, point, R, 255, -1, 8);
    Scalar summa = sum(h);
    imshow("PSF", h);
    outputImg = h / summa[0]; // Sum of each channel (only a channel has value here)
}
// Shift the spectrum image to make center of image as spectrum origin
void fftshift(const Mat& inputImg, Mat& outputImg)
{
    outputImg = inputImg.clone();
    int cx = outputImg.cols / 2;
    int cy = outputImg.rows / 2;
    Mat q0(outputImg, Rect(0, 0, cx, cy));
    Mat q1(outputImg, Rect(cx, 0, cx, cy));
    Mat q2(outputImg, Rect(0, cy, cx, cy));
    Mat q3(outputImg, Rect(cx, cy, cx, cy));
    Mat tmp;
    q0.copyTo(tmp);
    q3.copyTo(q0);
    tmp.copyTo(q3);
    q1.copyTo(tmp);
    q2.copyTo(q1);
    tmp.copyTo(q2);
}
// Convolve inputImg with H in freq domain
void filter2DFreq(const Mat& inputImg, Mat& outputImg, const Mat& H)
{
    Mat planes[2] = { Mat_<float>(inputImg.clone()), Mat::zeros(inputImg.size(), CV_32F) };
    Mat complexI;
    // 2nd channel: to store the complex's term after DFT
    merge(planes, 2, complexI);
    dft(complexI, complexI, DFT_SCALE);
    Mat planesH[2] = { Mat_<float>(H.clone()), Mat::zeros(H.size(), CV_32F) };
    Mat complexH;
    merge(planesH, 2, complexH);
    Mat complexIH;
    mulSpectrums(complexI, complexH, complexIH, 0);
    idft(complexIH, complexIH);
    split(complexIH, planes);
    outputImg = planes[0];
}
// Compute th Hw (Wiener filter)
void calcWnrFilter(const Mat& input_h_PSF, Mat& output_G, double nsr)
{
    Mat h_PSF_shifted;
    fftshift(input_h_PSF, h_PSF_shifted);
    Mat planes[2] = { Mat_<float>(h_PSF_shifted.clone()), Mat::zeros(h_PSF_shifted.size(), CV_32F) };
    Mat complexI;
    merge(planes, 2, complexI);
    dft(complexI, complexI);
    split(complexI, planes);
    Mat denom;
    pow(abs(planes[0]), 2, denom);
    denom += nsr;
    divide(planes[0], denom, output_G);
}

void test(const int& i)
{
    cout << "i = " << i << endl;
}

int main(int argc, char** argv)
{
    setbuf(stdout, NULL);

    test();

    { // Blur detection & deblur test
        // Kernel size
        Size kernel = Size(9, 9);
        int R = stoi(argv[1]);
        int SNR = stoi(argv[2]);

        Mat image;
        image = imread(argv[3], IMREAD_GRAYSCALE);
        imshow("original image", image);

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
        for (int i = 0; i < imgs.size(); i++)
        {
            // Check if image is blured (by Variance of Laplacian)
            printf("Focusness image[%d]: %f\n", i, varianceOfLaplacian(imgs[i]));
            // if(i == 0)
            // {
            //     imshow("image[0]", imgs[i]);
            //     continue;
            // }

            // Image deblur (by out of focus deblur)
            Mat img_deblur;
            // it needs to process even image only
            Rect roi = Rect(0, 0, imgs[i].cols & -2, imgs[i].rows & -2);
            // Hw calculation (start)
            Mat Hw, h;
            calcPSF(h, roi.size(), R);
            calcWnrFilter(h, Hw, 1.0 / double(SNR));
            // filtering (start)
            filter2DFreq(imgs[i](roi), img_deblur, Hw);

            img_deblur.convertTo(img_deblur, CV_8U);
            normalize(img_deblur, img_deblur, 0, 255, NORM_MINMAX);
            imshow(format("deblured image[%d]", i), img_deblur);
        }
    }

    waitKey(0);
    return 0;
}