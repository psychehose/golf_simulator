//
//  Shader.metal
//  golf_simulator
//
//  Created by 김호세 on 11/27/24.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
  float3 position [[attribute(0)]]; // 정점 위치
  float3 normal [[attribute(1)]]; // 법선 벡터
};

// 프래그먼트로 전달 되는 데이터
struct VertexOut {
  float4 position [[position]]; // 화면상 위치
  float3 worldPosition; // 월드 공간 위치
  float3 worldNormal; // 월드 공간 법선
};

// From Cpu
struct Uniforms {
  float4x4 modelMatrix;
  float4x4 viewMatrix;
  float4x4 projectionMatrix;
  float3x3 normalMatrix;
  float3 lightPosition;
  float3 cameraPosition;
};

vertex VertexOut vertexShader(const VertexIn in [[stage_in]],
                              constant Uniforms &uniforms [[buffer(1)]]) {
  VertexOut out;

  // 월드 공간으로 변환
  float4 worldPosition = uniforms.modelMatrix * float4(in.position, 1.0);

  // 화면 공간으로 변환
  out.position = uniforms.projectionMatrix * uniforms.viewMatrix * worldPosition;

  // 조명 계산을 위한 월드 공간 데이터 저장
  out.worldPosition = worldPosition.xyz;
  out.worldNormal = uniforms.normalMatrix * in.normal;

  return out;
}

fragment float4 fragmentShader(VertexOut in [[stage_in]],
                               constant Uniforms &uniforms [[buffer(1)]]) {

  // 법선 벡터 정규화
  float3 normal = normalize(in.worldNormal);

  // 광원 방향 계산
  float3 lightDirection = normalize(uniforms.lightPosition - in.worldPosition);

  // 시선 방향 계산
  float3 viewDirection = normalize(uniforms.cameraPosition - in.worldPosition);

  // 반사광 계산용
  float3 halfVector = normalize(lightDirection + viewDirection);

  // 조명 계산
  float3 ambient = float3(0.1); // 주변광
  float diffuse = max(0.0, dot(normal, lightDirection)); // 분산광
  float specular = pow(max(0.0, dot(normal, halfVector)), 32.0); // 반사광

  // 골프공 색상 (흰색)
  float3 baseColor = float3(1.0);
  float3 finalColor = baseColor * (ambient + diffuse) + float3(specular);

  return float4(finalColor, 1.0);
}

