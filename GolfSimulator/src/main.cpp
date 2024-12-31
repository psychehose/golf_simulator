#include "Simulator.h"

int main() {
  // 초기 설정: 초속 50m/s, 발사각 45도, 스핀 300rad/s
  Simulator simulator(50.0, 45.0, 300.0);
  simulator.run();
  return 0;
}