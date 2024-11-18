//
//  main.cpp
//  golf_simulator
//
//  Created by 김호세 on 11/18/24.
//

#include "GolfBall.hpp"
#include <iostream>

int main(int argc, const char * argv[]) 
{
  double initialVelocity = 70;
  double launchAngle = 15;
  double initialSpin = 100;
  double timeStep = 0.01;

  GolfBall ball(initialVelocity, launchAngle, initialSpin);

  while (ball.isFlying()) 
  {
      double x, y;
      ball.getPosition(x, y);
      std::cout << "Position: (" << x << ", " << y << ")\n";
      ball.update(timeStep);
  }
  return 0;
}
