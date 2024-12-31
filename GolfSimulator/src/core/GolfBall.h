//
//  GolfBall.h
//  golf_simulator
//
//  Created by 김호세 on 11/18/24.
//

#ifndef GolfBall_h
#define GolfBall_h

#include <iostream>

class GolfBall {
 private:
  const double gravity;          // 중력가속도: 9.81 m/s^2
  const double airDensity;       // 공기밀도: 1.225 kg/m^3
  const double mass;             // 골프공 질량: 0.0459kg
  const double radius;           // 골프공 반지름: 0.0213m
  const double dragCoefficient;  // 항력계수: 0.47
  const double liftCoefficient;  // 양력계수: 0.1

  double x, y;    // 골프공 위치
  double vx, vy;  // x축, y축 방향의 속도
  double spin;    // 회전속도 (rad/s)

 public:
  GolfBall(double initialVelocity, double launchAngle, double initialSpin);
  void update(double dt);
  bool isFlying() const;
  std::pair<double, double> getPosition() const;
};

#endif /* GolfBall_h */
