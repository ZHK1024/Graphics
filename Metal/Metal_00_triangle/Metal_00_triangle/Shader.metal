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
};

vertex Vertex vertexFunc(constant Vertex *vertexs [[buffer(0)]],
                         uint vid [[vertex_id]]) {
    return vertexs[vid];
}

fragment float4 fragmentFunc(Vertex in [[stage_in]]) {
    return float4(1);
}
