import Foundation
import MetalKit
import simd

class Camera {
  // 카메라 위치와 방향 설정
  var position: SIMD3<Float> // 카메라 3D 공간상 위치
  var target: SIMD3<Float> // 카메라가 바라보는 지점
  var up: SIMD3<Float> = [0, 1, 0] // 카메라 상단 방향 벡터

  // 프로젝션 매개변수
  var aspect: Float = 1.0 // 화면 비율(width/height)
  var fov: Float = Float.pi / 3 // 시야각(Field of View)
  var near: Float = 0.1 // 근거리 클리핑 평면
  var far: Float = 100 // 원거리 클리핑 평면

  init(position: SIMD3<Float>, target: SIMD3<Float>) {
    self.position = position
    self.target = target
  }

  var viewMatrix: float4x4 {
    // 1. 카메라 방향 벡터 계산
    let direction = normalize(target - position) // 시선 방향
    let right = normalize(cross(direction, up)) // 오른쪽 방향
    let newUp = normalize(cross(right, direction)) // 실제 상방 벡터

    // 2. 이동 행렬 (카메라 위치로 이동)
    let translation = float4x4(columns: (
      SIMD4<Float>(1, 0, 0, 0),
      SIMD4<Float>(0, 1, 0, 0),
      SIMD4<Float>(0, 0, 1, 0),
      SIMD4<Float>(-position.x, -position.y, -position.z, 1)
    ))

    // 3. 회전 행렬 (카메라 방향으로 회전)
    let rotation = float4x4(columns: (
      SIMD4<Float>(right.x, newUp.x, -direction.x, 0),
      SIMD4<Float>(right.y, newUp.y, -direction.y, 0),
      SIMD4<Float>(right.z, newUp.z, -direction.z, 0),
      SIMD4<Float>(0, 0, 0, 1)
    ))

    return rotation * translation
  }

  var projectionMatrix: float4x4 {
    // 1. 기본 값 계산
    let y = 1 / tan(fov * 0.5)    // 수직 스케일
    let x = y / aspect            // 수평 스케일
    let z = far / (far - near)    // 깊이 스케일
    let w = -z * near            // 깊이 오프셋

    // 2. 투영 행렬 생성
    return float4x4(columns: (
      SIMD4<Float>(x, 0, 0, 0),  // X 스케일
      SIMD4<Float>(0, y, 0, 0),  // Y 스케일
      SIMD4<Float>(0, 0, z, 1),  // Z 변환
      SIMD4<Float>(0, 0, w, 0)   // W 변환
    ))
  }
}
