//
//  Shader.metal
//  Metal_00_triangle
//
//  Created by ZHK on 2018/8/2.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

struct Vertex {
    float4 position [[position]];
    float4 color;
};

struct Matrix {
    float4x4 modelMatrix;
};

vertex Vertex vertexFun(constant Vertex *vertexs [[buffer(0)]],
                        constant Matrix &matrix [[buffer(1)]],
                        uint vid [[vertex_id]]) {
    
    Vertex in = vertexs[vid];
    Vertex out;
    out.position = matrix.modelMatrix * float4(in.position);
    out.color = in.color;
    
    return out;
}

fragment float4 fragmentFun(Vertex in [[stage_in]]) {
    return in.color;
}
