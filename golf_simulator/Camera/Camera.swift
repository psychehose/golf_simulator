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
  var near: Float = 0.1 // 가까운 클리핑 평면
  var far: Float = 100 // 먼 클리핑 평면

  init(position: SIMD3<Float>, target: SIMD3<Float>) {
    self.position = position
    self.target = target
  }

  var viewMatrix: float4x4 {
    // 시선 방향 계산
    let direction = normalize(target - position)
    let right = normalize(cross(direction, up))
    let newUp = normalize(cross(right, direction))

    let translation = float4x4(columns: (
      SIMD4<Float>(1, 0, 0, 0),
      SIMD4<Float>(0, 1, 0, 0),
      SIMD4<Float>(0, 0, 1, 0),
      SIMD4<Float>(-position.x, -position.y, -position.z, 1)
    ))

    let rotation = float4x4(columns: (
      SIMD4<Float>(right.x, newUp.x, -direction.x, 0),
      SIMD4<Float>(right.y, newUp.y, -direction.y, 0),
      SIMD4<Float>(right.z, newUp.z, -direction.z, 0),
      SIMD4<Float>(0, 0, 0, 1)
    ))

    return rotation * translation
  }

  var projectionMatrix: float4x4 {
    let y = 1 / tan(fov * 0.5)
    let x = y / aspect
    let z = far / (far - near)
    let w = -z * near

    return float4x4(columns: (
      SIMD4<Float>(x, 0, 0, 0),
      SIMD4<Float>(0, y, 0, 0),
      SIMD4<Float>(0, 0, z, 1),
      SIMD4<Float>(0, 0, w, 0)
    ))
  }
}
