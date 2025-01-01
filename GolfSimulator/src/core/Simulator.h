#ifndef Simulator_h
#define Simulator_h

#include <SFML/Graphics.hpp>
#include <SFML/Window.hpp>

#include "GolfBall.h"

class Simulator {
 private:
  struct EventVisitor {
    Simulator& simulator;
    // Window Closed
    void operator()(const sf::Event::Closed& event) {
      simulator.window.close();
    }

    // Keyboard
    void operator()(const sf::Event::KeyPressed& event) {
      if (event.code == sf::Keyboard::Key::X) {
        simulator.window.close();
      }
    }
    // 다른 이벤트들은 무시
    template <typename T>
    void operator()(const T& event) {}
  };

 private:
  sf::RenderWindow window;
  std::unique_ptr<GolfBall> golfBall;
  sf::CircleShape ballShape;

  const float SCALE = 10.0f;  // 1m = 10px
  const float TIMESTEP = 1.0f / 60.0f;

  sf::RectangleShape groundShape;

  sf::View camera;            // 카메라 뷰
  sf::Vector2f cameraCenter;  // 카메라 중심점
  const float CAMERA_SPEED = 0.1f;

 public:
  Simulator(double initialVelocity, double launchAngle, double initialSpin);

  void run();

 private:
  void handleEvents();
  void update();
  void render();
  void updateCamera();
};
#endif /* Simulator_h */