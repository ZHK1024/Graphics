//
//  MetalView.m
//  Metal_00_triangle
//
//  Created by ZHK on 2018/8/2.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import "MetalView.h"
#import <GLKit/GLKit.h>
#import <simd/simd.h>

@interface MetalView () <MTKViewDelegate>

@property (nonatomic, strong) id <MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id <MTLBuffer> vertexBuffer;
@property (nonatomic, strong) id <MTLBuffer> indexBuffer;
@property (nonatomic, strong) id <MTLBuffer> matrixBuffer;
@property (nonatomic, assign) CGFloat angle;

@end

@implementation MetalView

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.device = MTLCreateSystemDefaultDevice();
        self.delegate = self;
        _angle = 0.0f;
        [self shader];
        [self buffers];
    }
    return self;
}

#pragma mark -

/**
 渲染相关设置
 */
- (void)shader {
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertexFun"];
    renderPipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragmentFun"];
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:nil];
}

/**
 顶点数据
 */
- (void)buffers {
    
    // 顶点坐标
    float vertexs[] = {
        // 前面四个顶点
        // (x, y, z, w) (r, g, b, a)
        -0.5f,  0.5f,  0.5f,  1.0f, 1.0f, 0.0f, 0.0f, 1.0f, // 上左 (0)
         0.5f,  0.5f,  0.5f,  1.0f, 0.0f, 1.0f, 0.0f, 1.0f, // 上右 (1)
         0.5f, -0.5f,  0.5f,  1.0f, 0.0f, 0.0f, 1.0f, 1.0f, // 下左 (2)
        -0.5f, -0.5f,  0.5f,  1.0f, 1.0f, 1.0f, 1.0f, 1.0f, // 下右 (3)
        
        // 后面四个顶点
        -0.5f,  0.5f, -0.5f,  1.0f, 1.0f, 1.0f, 0.0f, 1.0f, // 上左 (4)
         0.5f,  0.5f, -0.5f,  1.0f, 0.0f, 1.0f, 1.0f, 1.0f, // 上右 (5)
         0.5f, -0.5f, -0.5f,  1.0f, 1.0f, 0.0f, 1.0f, 1.0f, // 下左 (6)
        -0.5f, -0.5f, -0.5f,  1.0f, 1.0f, 1.0f, 1.0f, 1.0f, // 下右 (7)
    };
    
    self.vertexBuffer = [self.device newBufferWithBytes:vertexs length:sizeof(vertexs) options:MTLResourceStorageModeShared];
    
    // 索引
    uint16 indexs[] = {
        // 正面
        0, 3, 2,
        2, 1, 0,
        // 背面
        4, 5, 6,
        6, 7, 4,
        // 左面
        7, 3, 0,
        0, 4, 7,
        // 右面
        1, 2, 6,
        6, 5, 1,
        // 上面
        0, 1, 5,
        5, 4, 0,
        // 下面
        6, 2, 3,
        3, 7, 6
    };
    
    self.indexBuffer = [self.device newBufferWithBytes:indexs length:sizeof(indexs) options:MTLResourceStorageModeShared];
    
    self.matrixBuffer = [self.device newBufferWithLength:sizeof(float) * 16 options:MTLResourceStorageModeShared];
}

/**
 渲染
 */
- (void)render {
    MTLRenderPassDescriptor *rpd = self.currentRenderPassDescriptor;
    rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.0f, 0.0f, 0.0f, 1.0f);
    
    id <MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id <MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id <MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    
    [encoder setRenderPipelineState:_pipelineState];
    [encoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    [encoder setVertexBuffer:_matrixBuffer offset:0 atIndex:1];
    // 逆时针为正面
    [encoder setFrontFacingWinding:MTLWindingCounterClockwise];
    // 背面剔除
    [encoder setCullMode:MTLCullModeBack];
    
    /*
     MTLPrimitiveTypePoint = 0,
     MTLPrimitiveTypeLine = 1,
     MTLPrimitiveTypeLineStrip = 2,
     MTLPrimitiveTypeTriangle = 3,
     MTLPrimitiveTypeTriangleStrip = 4,
     */
    [encoder drawIndexedPrimitives:MTLPrimitiveTypeTriangle
                        indexCount:_indexBuffer.length / sizeof(uint16)
                         indexType:MTLIndexTypeUInt16
                       indexBuffer:_indexBuffer
                 indexBufferOffset:0
                     instanceCount:12];
    
    [encoder endEncoding];
    [commandBuffer presentDrawable:self.currentDrawable];
    [commandBuffer commit];
    
    
}

- (void)update {
    _angle += M_PI / 120;
    
    // 倾斜
    GLKMatrix4  xm = GLKMatrix4Rotate(GLKMatrix4Identity, M_PI / 6, 0, 1, 0);
    // 旋转
    GLKMatrix4 rm = GLKMatrix4Rotate(GLKMatrix4Identity, _angle, 1, 1, 1);
    
    // 模型矩阵 (物体变换)
    GLKMatrix4 modelMatrix = GLKMatrix4Multiply(xm, rm);
    // 试图矩阵 (摄像机)
    GLKMatrix4 viewMatrix = GLKMatrix4Translate(GLKMatrix4Identity, 0, 0, -3);
    // 投影矩阵 (正投影/透视投影)
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeFrustum(-0.5, 0.5, -0.5, 0.5, 1, 10);
    
    GLKMatrix4 vm = GLKMatrix4Multiply(projectionMatrix, (GLKMatrix4Multiply(viewMatrix, modelMatrix)));
    
    void *pointer = _matrixBuffer.contents;
    memcpy(pointer, &vm, sizeof(simd_float4x4));
}

- (void)drawInMTKView:(nonnull MTKView *)view {
    [self update];
    [self render];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size {}

@end
