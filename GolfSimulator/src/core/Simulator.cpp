#include "Simulator.h"

Simulator::Simulator(double initialVelocity, double launchAngle,
                     double initialSpin)
    : window(sf::VideoMode(sf::Vector2u(800, 600)), "Golf Simulator"),
      golfBall(std::make_unique<GolfBall>(initialVelocity, launchAngle,
                                          initialSpin)) {
  // camera size - window size보다 2배 크기
  // 때문에 2배 더 넓은 시야 (축소 모드)
  camera.setSize(sf::Vector2f(1600.f, 1200.f));
  cameraCenter = sf::Vector2f(400.f, 300.f);
  camera.setCenter(cameraCenter);

  ballShape.setRadius(5.f);
  ballShape.setFillColor(sf::Color::White);
  ballShape.setOrigin(sf::Vector2f(5.f, 5.f));

  groundShape.setSize(sf::Vector2f(2000.f, 2.f));
  groundShape.setPosition(sf::Vector2f(-500.f, 500.f));
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
    } else if (const auto* keyEvent = event->getIf<sf::Event::KeyPressed>()) {
      if (keyEvent->code == sf::Keyboard::Key::X) {
        window.close();
      }
    }
  }
}

void Simulator::update() {
  if (golfBall->isFlying()) {
    golfBall->update(TIMESTEP);
  }
}

void Simulator::render() {
  window.clear(sf::Color(50, 50, 50));

  updateCamera();

  // 지면 그리기
  window.draw(groundShape);

  // 골프공 위치 업데이트 및 그리기
  auto position = golfBall->getPosition();
  // SFML 화면 최상단이 0 아래로 갈수록 y값이 증가.
  /*
  물리 좌표계    화면 좌표계
    ↑ +y         0 ─────
    │            │    ↓ +y
    │            │
  0 ─────      500 ─────
  */
  sf::Vector2f ballPosition(position.first * SCALE,
                            500.f - position.second * SCALE);
  ballShape.setPosition(ballPosition);
  window.draw(ballShape);

  window.display();
}

void Simulator::updateCamera() {
  auto ballPos = golfBall->getPosition();
  // x 위치만 공을 따라가고, y는 고정
  sf::Vector2f targetCenter(ballPos.first * SCALE, 300.f);

  // 부드러운 카메라 이동 (x축만)
  cameraCenter.x =
      cameraCenter.x + (targetCenter.x - cameraCenter.x) * CAMERA_SPEED;
  // y축은 고정
  cameraCenter.y = 300.f;

  camera.setCenter(cameraCenter);
  window.setView(camera);
}
