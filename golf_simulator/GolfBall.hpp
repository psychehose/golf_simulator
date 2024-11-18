//
//  GolfBall.hpp
//  golf_simulator
//
//  Created by 김호세 on 11/18/24.
//

#ifndef GolfBall_hpp
#define GolfBall_hpp

#include <iostream>

class GolfBall {
private:
    const double gravity;
    const double airDensity;
    const double mass;
    const double radius;
    const double dragCoefficient;
    const double liftCoefficient;

    double x, y;
    double vx, vy;
    double spin;

public:
    GolfBall(double initialVelocity, double launchAngle, double initialSpin);
    void update(double dt);
    bool isFlying() const;
    void getPosition(double& outX, double& outY) const;
};




#endif /* GolfBall_hpp */
