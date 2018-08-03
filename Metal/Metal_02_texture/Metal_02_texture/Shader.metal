//
//  Shader.metal
//  Metal02
//
//  Created by ZHK on 2018/7/2.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#include <metal_stdlib>

using namespace metal;

/*
 必须是 float4 的整倍数???
 */
struct Vertex {
    float4 position [[position]];
    float4 texCoord;
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
    out.texCoord = in.texCoord;
    return out;
}

fragment float4 fragmentFun(Vertex in [[stage_in]],
                            texture2d<float, access::sample> texture [[texture(0)]]
                            ) {
    constexpr sampler textureSampler(coord::normalized,
                                     address::repeat,
                                     min_filter::linear,
                                     mag_filter::linear,
                                     mip_filter::linear );

    float4 color = texture.sample(textureSampler,in.texCoord.xy).rgba;
//    if (sizeof(Vertex) == 48) {
//        return float4(0, 1, 0, 1);
//    }
//    if (in.st == 0.6) {
//        return float4(1, 0, 0, 1);
//    }
//    return float4(1);
    return color;
}
