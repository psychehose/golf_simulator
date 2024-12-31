#ifndef Simulator_h
#define Simulator_h

#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>

#include "GolfBall.h"

class Simulator {
 private:
  sf::RenderWindow window;
  GolfBall golfBall;
  sf::CircleShape ballShape;

  const float SCALE = 10.0f;
  const float TIMESTEP = 1.0f / 60.0f;

  sf::RectangleShape groundShape;

 public:
  Simulator(double initialVelocity, double launchAngle, double initialSpin);

  void run();

 private:
  void handleEvents();
  void update();
  void render();
};
#endif /* Simulator_h */