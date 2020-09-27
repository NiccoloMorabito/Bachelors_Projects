#include "ros/ros.h"
#include "turtlesim/SpawnCircle.h"
#include "turtlesim/Circle.h"
#include "cstdlib"
#include "turtlesim/Spawn.h"
#include "stdlib.h"
#include "time.h"
#include "string"
using namespace std;

int main(int argc, char **argv)
{
  // initialize random numbers
  srand (time(NULL));
  int randx = rand() % 11;
  int randy = rand() % 11;

  ros::init(argc, argv, "draw_circle_client");
  ros::NodeHandle n;

  // SPAWNCIRCLE SERVICE
  ros::ServiceClient client = n.serviceClient<turtlesim::SpawnCircle>("spawn_circle");
  turtlesim::SpawnCircle srv;
  // Creating a request
  turtlesim::Circle circle;
  srv.request.x = randx;
  srv.request.y = randy;
  // Calling the spawncircle service
  if (client.call(srv))
  {
    circle = (turtlesim::Circle)srv.response.circles[0];
  }
  else
  {
    ROS_ERROR("Failed to call service spawn_circle");
    return 1;
  }

  // Getting circle
  long int x = (long int)circle.x;
  long int y = (long int)circle.y;
  long int id = (long int)circle.id;

  ROS_INFO("Received a circle with id=%ld, x=%ld, y=%ld", id, x, y);

/*
  // SPAWN TURTLE SERVICE
  ros::ServiceClient spawn = n.serviceClient<turtlesim::Spawn>("spawn");
  turtlesim::Spawn spawn_srv;
  // Creating a request
  string name = "t" + std::to_string(id);
  spawn_srv.request.x = x;
  spawn_srv.request.y = y;
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
*/

  return 0;
}
