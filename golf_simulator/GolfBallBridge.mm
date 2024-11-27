//
//  GolfBallBridge.m
//  golf_simulator
//
//  Created by 김호세 on 11/27/24.
//

#import "GolfBallBridge.h"
#import "GolfBall.hpp"

@implementation GolfBallBridge {
  GolfBall* _ball;
}

- (instancetype)initWithVelocity:(double)velocity angle:(double)angle spin:(double)spin {
  self = [super init];
  if (self) {
    _ball = new GolfBall(velocity, angle, spin);
  }

  return self;
}

- (void)dealloc {
  delete _ball;
}

- (BOOL)isFlying {
  return _ball->isFlying();
}

- (void)updateWithTimeStep:(double)dt {
  _ball->update(dt);
}

- (double)positionX {
  double x, y;
  _ball->getPosition(x, y);
  return x;
}

- (double)positionY {
  double x, y;
  _ball->getPosition(x, y);
  return y;
}


@end
