//
//  GolfBallRenderer.swift
//  golf_simulator
//
//  Created by 김호세 on 11/24/24.
//

import MetalKit
import simd


final class GolfBallRenderer: NSObject {
  // MARK: - Properties

  private let device: MTLDevice
  private let commandQueue: MTLCommandQueue
  private let pipelineState: MTLRenderPipelineState

  private var ballVertexBuffer: MTLBuffer
  private var groundVertexBuffer: MTLBuffer
  private var uniformBuffer: MTLBuffer

  private var depthState: MTLDepthStencilState
  private var camera: Camera

  private var golfBall: GolfBallBridge
  private var lastUpdateTime: CFTimeInterval

  // cpu, gpu 둘 다 접근 가능해서 동적으로 업데이트되는 데이터 처리에 적합 (자주 바뀌는 데이터)

  struct Uniforms {
    var modelMatrix: float4x4 // 골프공의 위치를 이동시키는 변환 행렬
    var viewMatrix: float4x4 // 카메라의 관점에서 월드를 바라보는 변환 행렬, 카메라의 위치와 방향에 따라 모든 객체들의 위치를 변환
    var projectionMatrix: float4x4 // 3d 공간을 2d 화면으로 프로젝션 하는 변환 행렬
    var normalMatrix: float3x3 // 법선 벡터를 변환하기 위한 행렬
    var lightPosition: SIMD3<Float>
    var cameraPosition: SIMD3<Float>
  }


  init?(
    metalView: MTKView,
    velocity: Double,
    angle: Double,
    spin: Double
  ) {

    golfBall = GolfBallBridge(velocity: velocity, angle: angle, spin: spin)
    lastUpdateTime = CACurrentMediaTime()

    guard
      let device = MTLCreateSystemDefaultDevice(),
      let commandQueue = device.makeCommandQueue()
    else {
      return nil
    }

    self.device = device
    self.commandQueue = commandQueue
    metalView.device = device

    // MARK: - 깊이 테스트 설정
    // 깊이 텍스트 포맷 32bit float으로 설정
    metalView.depthStencilPixelFormat = .depth32Float

    let depthDescriptor = MTLDepthStencilDescriptor()
    // 새로운 Depth가 들어온 경우 기존의 Depth와 어떻게 비교할 지에 대한 비교함수 설정
    // 새로운 픽셀의 깊이 값이 기존 깊이 값보다 작거나 같을 때만 렌더링
    depthDescriptor.depthCompareFunction = .lessEqual
    // 현재 Depth를 비교를 위해 저장해야함.
    depthDescriptor.isDepthWriteEnabled = true

    guard
      let depthState = device.makeDepthStencilState(descriptor: depthDescriptor)
    else {
      return nil
    }

    self.depthState = depthState

    // MARK: - 카메라 설정
    self.camera = Camera(
      position: SIMD3<Float>(0, 2, 5),
      target: SIMD3<Float>(0,0,0)
    )

    // MARK: - 버퍼 생성
    // 각 파라미터는 어떤 역할을?
    guard
      let uniformBuffer = device.makeBuffer(
        length: MemoryLayout<Uniforms>.size, // 버퍼 크기
        options: .storageModeShared // cpu,gpu 접근 가능
      )
    else {
      return nil
    }
    self.uniformBuffer = uniformBuffer

    // MARK: - 골프공과 지면 메시 생성

    let (ballBuffer, groundBuffer) = Self.createGeometry(device: device)

    guard
      let ballBuffer = ballBuffer,
      let groundBuffer = groundBuffer
    else { return nil }

    self.ballVertexBuffer = ballBuffer
    self.groundVertexBuffer = groundBuffer

    // MARK: - 렌더링 파이프라인 설정

    // 셰이더 함수 로드
    guard
      let library = device.makeDefaultLibrary(),
      let vertexFunction = library.makeFunction(name: "vertexShader"),
      let fragmentFunction = library.makeFunction(name: "fragmentShader")
    else {
      return nil
    }

    // 렌더링 파이프라인 구성 설정
    // 셰이더 함수 연결
    let pipelineDescriptor = MTLRenderPipelineDescriptor()
    pipelineDescriptor.vertexFunction = vertexFunction
    pipelineDescriptor.fragmentFunction = fragmentFunction
    pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
    pipelineDescriptor.depthAttachmentPixelFormat = metalView.depthStencilPixelFormat

    // 버텍스 디스크립터 설정
    let vertexDescriptor = MTLVertexDescriptor()

    // 위치 데이터 (x,y,z)
    vertexDescriptor.attributes[0].format = .float3
    vertexDescriptor.attributes[0].offset = 0
    vertexDescriptor.attributes[0].bufferIndex = 0

    // 법선 데이터 (nx, ny, nz)
    vertexDescriptor.attributes[1].format = .float3
    vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
    vertexDescriptor.attributes[1].bufferIndex = 0

    // 전체 버텍스 크기 - GPU에게 버텍스 버퍼의 데이터 구조를 알려줘서 셰이더가 올바르게 데이터 읽을 수 있음
    vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride * 2 // 크기
    pipelineDescriptor.vertexDescriptor = vertexDescriptor

    guard
      let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor)
    else {
      return nil
    }
    self.pipelineState = pipelineState

    super.init()
    metalView.delegate = self
    metalView.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)

  }

}

// MARK: - Geometry Creation
extension GolfBallRenderer {

  static func createGeometry(device: MTLDevice) -> (MTLBuffer?, MTLBuffer?) {
    // 1. 골프공 메시 데이터 생성 (UV 구)
    var ballVertices: [Float] = []
    let segments = 32 // 구체의 해상도
    let radius: Float = 0.0213 // 골프공 반지름 (meter)

    // 구체를 생성하는 과정 - lat, lng (위도, 경도)를 이용해서
    // lat: -pi/2 ~ pi/2
    // lng: 0 ~ 2pi
    for i in 0 ... segments {
      let lat = Float.pi * (-0.5 + Float(i) / Float(segments))

      // y 좌표
      let y = radius * sin(lat)
      // 현재 위도에서의 원의 반지름
      let conLat = radius * cos(lat)

      // 경도 계산
      for j in 0 ... segments {
        let lng = 2 * Float.pi * Float(j) / Float(segments)
        let x = conLat * cos(lng)
        let z = conLat * sin(lng)

        // 정점 위치
        ballVertices.append(x)
        ballVertices.append(y)
        ballVertices.append(z)

        // 법선 벡터 저장. (정규화 된 방향)
        ballVertices.append(x/radius)
        ballVertices.append(y/radius)
        ballVertices.append(z/radius)
      }
    }
    // 2. 지면 메시 생성
    // 간단한 사각형 지면
    let groundVertices: [Float] = [
      // 위치       법선벡터
      -50, 0, -50, 0, 1, 0,  // 왼쪽 뒤
       50, 0, -50, 0, 1, 0,  // 오른쪽 뒤
       50, 0,  50, 0, 1, 0,  // 오른쪽 앞

       -50, 0, -50, 0, 1, 0,  // 왼쪽 뒤
       50, 0,  50, 0, 1, 0,  // 오른쪽 앞
       -50, 0,  50, 0, 1, 0   // 왼쪽 앞
    ]

    // 3. Metal 버퍼 생성

    guard
      let ballBuffer = device.makeBuffer(
        bytes: ballVertices,
        length: ballVertices.count * MemoryLayout<Float>.stride,
        options: []
      ),
      let groundBuffer = device.makeBuffer(
        bytes: groundVertices,
        length: groundVertices.count * MemoryLayout<Float>.stride,
        options: []
      )
    else {
      return (nil, nil)
    }
    return (ballBuffer, groundBuffer)
  }
}

extension GolfBallRenderer: MTKViewDelegate {
  func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    camera.aspect = Float(size.width / size.height)
  }

  func draw(in view: MTKView) {

    let currentTime = CACurrentMediaTime()
    let deltaTime = currentTime - lastUpdateTime
    lastUpdateTime = currentTime

    golfBall.update(withTimeStep: deltaTime)
    let ballX = Float(golfBall.positionX)
    let ballY = Float(golfBall.positionY)

    guard golfBall.isFlying(),
          let commandBuffer = commandQueue.makeCommandBuffer(),
          let desciptor = view.currentRenderPassDescriptor,
          let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: desciptor)
    else {
      return
    }


    // 유니폼 데이터 업데이트
    var uniforms = Uniforms(
      modelMatrix: float4x4(translation: SIMD3<Float>(ballX, ballY, 0)),
      viewMatrix: camera.viewMatrix,
      projectionMatrix: camera.projectionMatrix,
      normalMatrix: float3x3(normalFrom4x4: camera.viewMatrix),
      lightPosition: SIMD3<Float>(x: 5, y: 5, z: 5),
      cameraPosition: camera.position
    )

    memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.size)

    encoder.setRenderPipelineState(pipelineState)
    encoder.setDepthStencilState(depthState)
    encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

    // GPU 메모리로 데이터 복사
    memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.size)

    // render state 설정
    encoder.setRenderPipelineState(pipelineState)
    encoder.setDepthStencilState(depthState)
    // 버퍼 바인딩
    encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)

    // 골프공 렌더링
    encoder.setVertexBuffer(ballVertexBuffer, offset: 0, index: 0)
    encoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: ballVertexBuffer.length / MemoryLayout<Float>.stride / 6
    )

    // 지면 렌더링
    encoder.setVertexBuffer(groundVertexBuffer, offset: 0, index: 0)
    encoder.drawPrimitives(
      type: .triangle,
      vertexStart: 0,
      vertexCount: 6
    )

    encoder.endEncoding()

    if let drawable = view.currentDrawable {
      commandBuffer.present(drawable)
    }
    commandBuffer.commit()

  }

}

extension float4x4 {
  init(translation: SIMD3<Float>) {
    self = matrix_identity_float4x4 // 단위 행렬
    columns.3.x = translation.x // 4번째 열에 이동량
    columns.3.y = translation.y
    columns.3.z = translation.z
  }
}

extension float3x3 {
  init(normalFrom4x4 matrix: float4x4) {
    self.init(
      SIMD3<Float>(matrix.columns.0.x, matrix.columns.0.y, matrix.columns.0.z),
      SIMD3<Float>(matrix.columns.1.x, matrix.columns.1.y, matrix.columns.1.z),
      SIMD3<Float>(matrix.columns.2.x, matrix.columns.2.y, matrix.columns.2.z)
    )
  }
}
