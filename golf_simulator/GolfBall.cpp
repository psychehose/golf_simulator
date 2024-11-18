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
    double angleRad = launchAngle * M_PI / 180.0;
    vx = initialVelocity * cos(angleRad);
    vy = initialVelocity * sin(angleRad);
    spin = initialSpin;
}

void GolfBall::update(double dt) 
{
    double velocity = sqrt(vx*vx + vy*vy);
    double area = M_PI * radius * radius;
    double dragForce = 0.5 * airDensity * dragCoefficient * area * velocity * velocity;
    double liftForce = 0.5 * airDensity * liftCoefficient * area * velocity * velocity;

    double ax = -(dragForce * vx / velocity) / mass;
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
