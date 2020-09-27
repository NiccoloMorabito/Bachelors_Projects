#include "ros/ros.h"
#include "turtlesim/SpawnCircle.h"
#include "turtlesim/Circle.h"
#include "turtlesim/Spawn.h"
#include "string"
using namespace std;

int id = 0;
ros::Publisher pub;

bool getCircles(turtlesim::SpawnCircle::Request  &req,
         turtlesim::SpawnCircle::Response &res)
{
  // Circle creation
  ROS_INFO("Creating circle...");
  turtlesim::Circle circle;
  circle.id = id++;
  circle.x = req.x;
  circle.y = req.y;
  res.circles = {circle};
  ROS_INFO("Creation completed.");

  // Publish circle in the topic "circles"
  pub.publish(circle);

  // SPAWN A TURTLE in the center of the circle
  ros::NodeHandle n;
  ros::ServiceClient spawn = n.serviceClient<turtlesim::Spawn>("spawn");
  turtlesim::Spawn spawn_srv;
  // Creating a request
  string name = "t" + std::to_string(id-1);
  spawn_srv.request.x = req.x;
  spawn_srv.request.y = req.y;
  spawn_srv.request.theta = 0;
  spawn_srv.request.name = name;
  // Calling the spawn service
  if (spawn.call(spawn_srv))
  {
    name = spawn_srv.response.name.c_str();
    ROS_INFO_STREAM("Turtle named " << name << " has been created.");
  }
  else
  {
    ROS_ERROR("Failed to call service spawn");
    return 1;
  }

  return true;
}


int main(int argc, char **argv)
{
  ros::init(argc, argv, "draw_circle_server");
  ros::NodeHandle n;
  ros::ServiceServer service = n.advertiseService("spawn_circle", getCircles);
  ROS_INFO("Ready to use spawn circle");
  pub = n.advertise<turtlesim::Circle>("circles", 1000);
  ros::Rate loop_rate(10);

  while (ros::ok())
  {
    ros::spinOnce();
    loop_rate.sleep();
  }

  return 0;
}
