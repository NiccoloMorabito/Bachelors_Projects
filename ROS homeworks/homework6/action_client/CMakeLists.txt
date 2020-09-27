#add_library(thin_navigation_localizer_library  SHARED
#  localization_filter.cpp 
#  localization_filter.h
#)

#target_link_libraries(thin_navigation_localizer_library
#  thin_navigation_nav_global_library
#  ${OpenCV_LIBS} 
#)

add_executable(action_client
  action_client.cpp
)

target_link_libraries(action_client
  thin_navigation_localizer_library
  thin_navigation_ros_utils_library
  thin_navigation_nav_global_library
  ${catkin_LIBRARIES}
  ${OpenCV_LIBS} 
)
