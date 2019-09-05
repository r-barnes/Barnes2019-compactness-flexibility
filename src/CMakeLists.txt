cmake_minimum_required (VERSION 3.9)

add_executable(augmenter.exe augmenter.cpp)

target_link_libraries(augmenter.exe
PRIVATE
  compactnesslib
)

add_executable(koch.exe koch.cpp)

install(
  TARGETS koch.exe augmenter.exe
  RUNTIME DESTINATION ${CMAKE_SOURCE_DIR}/bin
)