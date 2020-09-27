#include "ros/ros.h"
#include "cstdlib"
#include "turtlesim/Pose.h"
#include "turtlesim/Circle.h"
#include "turtlesim/GetCircles.h"
#include "turtlesim/Kill.h"

turtlesim::Circle * circles = (turtlesim::Circle*)malloc(sizeof(turtlesim::Circle));
// Number of circles
int c = 0;

void getPose(const turtlesim::Pose& pose)
{
  // check if the turtle is in one of the circles
  for (int i=0; i<c; i++)
  {
    if ((int)circles[i].x == (int)pose.x && (int)circles[i].y == (int)pose.y)
    {
      // Turtle in the i-th circle!
      // Delete circle (turtle)
      ros::NodeHandle n;
      ros::ServiceClient kill = n.serviceClient<turtlesim::Kill>("kill");
      turtlesim::Kill kill_srv;
      kill_srv.request.name = "t" + std::to_string(circles[i].id);
      // Calling the kill service
      if (kill.call(kill_srv))
      {
	ROS_INFO_STREAM("Turtle killed!");
      }
      else
      {
        ROS_ERROR("Failed to kill turtle");
      }
      // Delete the killed turtle from circles
      if (i<c)
      {
        c--; // reducing size of array
        for (int j=i; j<c; j++)
        {
          circles[j] = circles[j+1];
        }
      }
    }
    
  }
}

void getCircle(const turtlesim::Circle& circle)
{
  ROS_INFO("New turtle: x=%ld, y=%ld", (int)circle.x, (int)circle.y);
  circles[c] = circle;
  c++;
  
  // incrementing circles size for the next circle
  circles = (turtlesim::Circle*)realloc(circles, sizeof(turtlesim::Circle) * (c+1));
}




int main(int argc, char **argv)
{

  ros::init(argc, argv, "delete_circle");
  ros::NodeHandle nh;

  ros::Subscriber sub1 = nh.subscribe("/turtle1/pose", 1000, getPose);
  ros::Subscriber sub2 = nh.subscribe("/circles", 1000, getCircle);

  ros::spin();

  return 0;
}
