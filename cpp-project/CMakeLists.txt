cmake_minimum_required(VERSION 3.2.2)

project (computecpp_sample)

set(CMAKE_CXX_STANDARD 17)

add_executable(
  ${SAMPLE_NAME}
  ${CMAKE_CURRENT_SOURCE_DIR}/src/exercises/${SAMPLE_NAME}.cpp
)
