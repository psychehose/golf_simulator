//
//  MetalRenderEngine.swift
//  golf_simulator
//
//  Created by 김호세 on 11/24/24.
//

import Metal
import MetalKit

@objc 
class MetalRenderEngineBridge: NSObject {
  private let renderEngine: MetalRenderEngine
  
  override init() {
    self.renderEngine = MetalRenderEngine(metalView: MTKView())!
    super.init()
  }

  @objc 
  func initialize() {
    renderEngine.initialize()
  }
  @objc
  func cleanup() {
    renderEngine.cleanup()
  }
  @objc
  func beginFrame() {
    renderEngine.beginFrame()
  }
  @objc
  func endFrame() {
    renderEngine.endFrame()
  }
  @objc
  func render() {
    renderEngine.render()
  }
  @objc
  func resize(width: UInt32, height: UInt32) {
    renderEngine.resize(width: width, height: height)
  }
}

@objc
final class MetalRenderEngine: NSObject {
    // MARK: - Properties
    private let device: MTLDevice
    private let commandQueue: MTLCommandQueue
    private let pipelineState: MTLRenderPipelineState
    private let depthState: MTLDepthStencilState
    private let camera: Camera
    
    private var uniformBuffer: MTLBuffer
    private var ballVertexBuffer: MTLBuffer
    private var groundVertexBuffer: MTLBuffer
    
    private var metalView: MTKView?
    
    // MARK: - Uniforms
    struct Uniforms {
        var modelMatrix: float4x4
        var viewMatrix: float4x4
        var projectionMatrix: float4x4
        var normalMatrix: float3x3
        var lightPosition: SIMD3<Float>
        var cameraPosition: SIMD3<Float>
    }
    
    // MARK: - Initialization
    @objc
    init?(metalView: MTKView) {
        guard let device = MTLCreateSystemDefaultDevice(),
              let commandQueue = device.makeCommandQueue() else {
            return nil
        }
        
        self.device = device
        self.commandQueue = commandQueue
        self.metalView = metalView
        
        metalView.device = device
        metalView.clearColor = MTLClearColor(red: 0.7, green: 0.9, blue: 1.0, alpha: 1.0)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.depthStencilPixelFormat = .depth32Float
        
        // Initialize camera
        self.camera = Camera(
            position: SIMD3<Float>(0, 2, 5),
            target: SIMD3<Float>(0, 0, 0)
        )
        
        // Create depth state
        let depthDescriptor = MTLDepthStencilDescriptor()
        depthDescriptor.depthCompareFunction = .lessEqual
        depthDescriptor.isDepthWriteEnabled = true
        
        guard let depthState = device.makeDepthStencilState(descriptor: depthDescriptor) else {
            return nil
        }
        self.depthState = depthState
        
        // Create buffers
        guard let uniformBuffer = device.makeBuffer(
            length: MemoryLayout<Uniforms>.size,
            options: .storageModeShared
        ) else {
            return nil
        }
        self.uniformBuffer = uniformBuffer
        
        // Create geometry
        let (ballBuffer, groundBuffer) = Self.createGeometry(device: device)
        guard let ballBuffer = ballBuffer,
              let groundBuffer = groundBuffer else {
            return nil
        }
        self.ballVertexBuffer = ballBuffer
        self.groundVertexBuffer = groundBuffer
        
        // Create pipeline state
        guard let library = device.makeDefaultLibrary(),
              let vertexFunction = library.makeFunction(name: "vertexShader"),
              let fragmentFunction = library.makeFunction(name: "fragmentShader") else {
            return nil
        }
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        pipelineDescriptor.depthAttachmentPixelFormat = metalView.depthStencilPixelFormat
        
        // Set vertex descriptor
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.attributes[1].format = .float3
        vertexDescriptor.attributes[1].offset = MemoryLayout<SIMD3<Float>>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<SIMD3<Float>>.stride * 2
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        guard let pipelineState = try? device.makeRenderPipelineState(descriptor: pipelineDescriptor) else {
            return nil
        }
        self.pipelineState = pipelineState
        
        super.init()
        metalView.delegate = self
    }
    
    // MARK: - Public Methods
    @objc
    func initialize() {
    }
    
    @objc
    func cleanup() {
        metalView = nil
    }
    
    @objc
    func beginFrame() {
        // Frame 시작 시 필요한 작업
    }
    
    @objc
    func endFrame() {
        // Frame 종료 시 필요한 작업
    }
    
    @objc
    func render() {
        guard let view = metalView,
              let commandBuffer = commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor,
              let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        
        // Update uniforms
        var uniforms = Uniforms(
            modelMatrix: matrix_identity_float4x4,
            viewMatrix: camera.viewMatrix,
            projectionMatrix: camera.projectionMatrix,
            normalMatrix: float3x3(normalFrom4x4: camera.viewMatrix),
            lightPosition: SIMD3<Float>(5, 5, 5),
            cameraPosition: camera.position
        )
        
        memcpy(uniformBuffer.contents(), &uniforms, MemoryLayout<Uniforms>.size)
        
        encoder.setRenderPipelineState(pipelineState)
        encoder.setDepthStencilState(depthState)
        encoder.setVertexBuffer(uniformBuffer, offset: 0, index: 1)
        
        // Render ball
        encoder.setVertexBuffer(ballVertexBuffer, offset: 0, index: 0)
        encoder.drawPrimitives(
            type: .triangle,
            vertexStart: 0,
            vertexCount: ballVertexBuffer.length / MemoryLayout<Float>.stride / 6
        )
        
        // Render ground
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
    
    @objc
    func resize(width: UInt32, height: UInt32) {
        camera.aspect = Float(width) / Float(height)
    }
}

// MARK: - MTKViewDelegate
extension MetalRenderEngine: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(size.width / size.height)
    }
    
    func draw(in view: MTKView) {
        render()
    }
}

// MARK: - Geometry Creation
private extension MetalRenderEngine {
    static func createGeometry(device: MTLDevice) -> (MTLBuffer?, MTLBuffer?) {
        // Ball vertices
        var ballVertices: [Float] = []
        let segments = 32
        let radius: Float = 0.0213
        
        for i in 0...segments {
            let lat = Float.pi * (-0.5 + Float(i) / Float(segments))
            let y = radius * sin(lat)
            let conLat = radius * cos(lat)
            
            for j in 0...segments {
                let lng = 2 * Float.pi * Float(j) / Float(segments)
                let x = conLat * cos(lng)
                let z = conLat * sin(lng)
                
                ballVertices.append(x)
                ballVertices.append(y)
                ballVertices.append(z)
                
                ballVertices.append(x/radius)
                ballVertices.append(y/radius)
                ballVertices.append(z/radius)
            }
        }
        
        // Ground vertices
        let groundVertices: [Float] = [
            -50, 0, -50, 0, 1, 0,
             50, 0, -50, 0, 1, 0,
             50, 0,  50, 0, 1, 0,
            -50, 0, -50, 0, 1, 0,
             50, 0,  50, 0, 1, 0,
            -50, 0,  50, 0, 1, 0
        ]
        
        guard let ballBuffer = device.makeBuffer(
            bytes: ballVertices,
            length: ballVertices.count * MemoryLayout<Float>.stride,
            options: []
        ),
        let groundBuffer = device.makeBuffer(
            bytes: groundVertices,
            length: groundVertices.count * MemoryLayout<Float>.stride,
            options: []
        ) else {
            return (nil, nil)
        }
        
        return (ballBuffer, groundBuffer)
    }
}

// MARK: - Matrix Extensions
extension float4x4 {
    init(translation: SIMD3<Float>) {
        self = matrix_identity_float4x4
        columns.3.x = translation.x
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
