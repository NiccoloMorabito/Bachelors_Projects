#include <ros/ros.h>
#include <move_base_msgs/MoveBaseAction.h>
#include <actionlib/client/simple_action_client.h>
#include <iostream>
#include <thread>
#include <chrono>

typedef actionlib::SimpleActionClient<move_base_msgs::MoveBaseAction> MoveBaseClient;

int main(int argc, char** argv){
	ros::init(argc, argv, "action_client");

	// tell the action client to spin a thread by default
	MoveBaseClient ac("move_base", true);

	// wait for the action server to come up
	while(!ac.waitForServer(ros::Duration(5.0))){
		ROS_INFO("Waiting for the move_base action server to come up");
	}

	// 1)
	// send a target goal to the robot to move
	move_base_msgs ::MoveBaseGoal move_goal;

	move_goal.target_pose.header.frame_id = "base_link";
	move_goal.target_pose.header.stamp = ros::Time::now();
	move_goal.target_pose.pose.position.x = -18.645;
	move_goal.target_pose.pose.position.y = 21.633;
	move_goal.target_pose.pose.position.z = 0;
	move_goal.target_pose.pose.orientation.x = 0.0;
	move_goal.target_pose.pose.orientation.y = 0.0;
	move_goal.target_pose.pose.orientation.z = 1.0;
	move_goal.target_pose.pose.orientation.w = -0.021;
	ROS_INFO("Sending move goal..." );
	ac.sendGoal(move_goal);
	ROS_INFO("Move goal sent!");

	// 2)
	// cancel the goal after 60 seconds
	std::cout << "Countdown:\n";
	for (int i=60; i>0; --i) {
		std::cout << i << std::endl;
		std::this_thread::sleep_for (std::chrono::seconds(1));
	}
	ROS_INFO("Canceling move goal...");
	ac.cancelAllGoals();
	ROS_INFO("Move goal canceled.");

	// 3)
	// send a target goal to get back to the initial position
	move_base_msgs::MoveBaseGoal return_goal;

	return_goal.target_pose.header.frame_id = "base_link";
	return_goal.target_pose.header.stamp = ros::Time::now();
	return_goal.target_pose.pose.position.x = -11.277;
	return_goal.target_pose.pose.position.y = 23.266;
	return_goal.target_pose.pose.position.z = 0.0;
	return_goal.target_pose.pose.orientation.x = 0.0;
	return_goal.target_pose.pose.orientation.y = 0.0;
	return_goal.target_pose.pose.orientation.z = 1.0;
	return_goal.target_pose.pose.orientation.w = -0.021;
	ROS_INFO("Sending return goal...");
	ac.sendGoal(return_goal);

	ac.waitForResult();

	ROS_INFO("Return goal sent!");

	return 0;
}





