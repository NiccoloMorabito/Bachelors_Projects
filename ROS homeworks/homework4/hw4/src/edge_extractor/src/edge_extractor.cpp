#include <ros/ros.h>
#include <opencv2/highgui/highgui.hpp>
#include <cv_bridge/cv_bridge.h>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#define DELAY_CAPTION 1500
#define DELAY_BLUR 100
#define MAX_KERNEL_LENGTH 31

char WINDOW_NAME[] = "View";

void imageCallback(const sensor_msgs::CompressedImageConstPtr& msg)
{
  try
  {
    // Convert compressed image data to cv::Mat
    cv::Mat image = cv::imdecode(cv::Mat(msg->data), 1);

    // Convert cv::Mat to a grayscale
    cv::Mat greyImage;
    cv::cvtColor(image, greyImage, CV_BGR2GRAY);

    /// Apply Gaussian blur
    cv::Mat edges;
    for (int i = 1; i < MAX_KERNEL_LENGTH; i = i+2)
    {
         GaussianBlur(greyImage, edges, cv::Size(i, i), 0, 0);
    }

    // Apply Canny detector
    int lowThreshold = 10;
    int kernel_size = 3;
    Canny(edges, edges, lowThreshold, lowThreshold*3, kernel_size);

    // Concatenate two images
    /*
    cv::Size s1 = image.size();
    cv::Size s2 = dst.size();

    cv::Mat output(s1.height, s1.width + s2.width, dst.type()); // the two images have a different type

    cv::Mat help1(output, cv::Rect(0, 0, s1.width, s1.height));
    cv::Mat help2(output, cv::Rect(s1.width, 0, s2.width, s2.height));

    image.copyTo(help1);
    dst.copyTo(help2);
    */

    // Show both images
    cv::imshow("image", image);
    cv::imshow("edges", edges);
    cv::waitKey(10);
  }
  catch (...)
  {
    ROS_ERROR("Error in image conversions!");
  }
}

int main(int argc, char **argv)
{
    ros::init(argc, argv, "image_listener");
    ros::NodeHandle nh;
    // Subscribe to topic of rosbag
    ros::Subscriber sub = nh.subscribe("/default/camera_node/image/compressed", 1, imageCallback);
    ros::spin();
}
