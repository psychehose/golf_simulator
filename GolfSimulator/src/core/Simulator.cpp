#include "Simulator.h"

Simulator::Simulator(double initialVelocity, double launchAngle,
                     double initialSpin)
    : window(sf::VideoMode(sf::Vector2u(800, 600)), "Golf Simulator"),
      golfBall(initialVelocity, launchAngle, initialSpin) {
  ballShape.setRadius(5.f);
  ballShape.setFillColor(sf::Color::White);
  ballShape.setOrigin(sf::Vector2f(5.f, 5.f));

  groundShape.setSize(sf::Vector2f(800.f, 2.f));
  groundShape.setPosition(sf::Vector2f(0.f, 500.f));
  groundShape.setFillColor(sf::Color::Green);

  // 수직동기화 활성화
  window.setVerticalSyncEnabled(true);
}

void Simulator::run() {
  while (window.isOpen()) {
    handleEvents();
    update();
    render();
  }
}

void Simulator::handleEvents() {
  if (auto event = window.pollEvent()) {
    if (event->is<sf::Event::Closed>()) {
      window.close();
    }
  }
}

void Simulator::update() {
  if (golfBall.isFlying()) {
    golfBall.update(TIMESTEP);
  }
}

void Simulator::render() {
  window.clear(sf::Color(50, 50, 50));

  // 지면 그리기
  window.draw(groundShape);

  // 골프공 위치 업데이트 및 그리기
  auto position = golfBall.getPosition();
  sf::Vector2f ballPosition(position.first * SCALE, 500.f - position.second * SCALE);
  ballShape.setPosition(ballPosition);
  window.draw(ballShape);

  window.display();
}
