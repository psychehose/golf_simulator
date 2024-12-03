//
//  GolfBallBridge.h
//  golf_simulator
//
//  Created by 김호세 on 11/27/24.
//

#import <Foundation/Foundation.h>

#ifndef GolfBallBridge_h
#define GolfBallBridge_h

#ifdef __cplusplus
class GolfBall;
#else
typedef struct GolfBall GolfBall;
#endif

@interface GolfBallBridge : NSObject

@property (nonatomic, readonly) double positionX;
@property (nonatomic, readonly) double positionY;

- (instancetype)initWithVelocity: (double)velocity angle:(double)angle spin:(double) spin;
- (void)updateWithTimeStep:(double)dt;
- (BOOL)isFlying;

@end

#endif /* GolfBallBridge_h */
