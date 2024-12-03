//
//  GolfBall.cpp
//  golf_simulator
//
//  Created by 김호세 on 11/18/24.
//

#include "GolfBall.hpp"
#include <cmath>

GolfBall::GolfBall(double initialVelocity,double launchAngle,double initialSpin) :
gravity(9.81), airDensity(1.225),mass(0.0459), radius(0.0213), dragCoefficient(0.47), liftCoefficient(0.1)
{
  x = 0;
  y = 0;
  double angleRad = launchAngle * M_PI / 180.0; // degree -> radian 변환
  vx = initialVelocity * cos(angleRad); // 초기 속도의 수평 성분
  vy = initialVelocity * sin(angleRad); // 초기 속도의 수직 성분
  spin = initialSpin; // for 마그누스 효과
}

void GolfBall::update(double dt)
{
  double velocity = sqrt(vx*vx + vy*vy); // 스칼라
  double area = M_PI * radius * radius; // 골프공 단면적

  // 공기저항력 계산
  double dragForce = 0.5 * airDensity * dragCoefficient * area * velocity * velocity;
  // 양력 계산
  double liftForce = 0.5 * airDensity * liftCoefficient * area * velocity * velocity;

  // 가속도는 F = ma에서 구하기 a = f/m
  // x축 가속도:
  // cos(Theta) = vx / velocity 공기저항력 벡터 분해
  double ax = -(dragForce * vx / velocity) / mass;
  // y축 가속도:
  // sin(Theta) = vy / velocity 공기저항력 벡터 분해
  double ay = -gravity - (dragForce * vy / velocity) / mass + (liftForce / mass);

  x += vx * dt;
  y += vy * dt;
  vx += ax * dt;
  vy += ay * dt;
}

bool GolfBall::isFlying() const
{
  return y >= 0;
}

void GolfBall::getPosition(double& outX, double& outY) const
{
  outX = x;
  outY = y;
}
