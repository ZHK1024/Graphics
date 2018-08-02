//
//  MetalView.m
//  Metal_00_triangle
//
//  Created by ZHK on 2018/8/2.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import "MetalView.h"

@interface MetalView ()

@property (nonatomic, strong) id <MTLRenderPipelineState> pipelineState;
@property (nonatomic, strong) id <MTLBuffer> vertexBuffer;

@end

@implementation MetalView

#pragma mark - Init

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.device = MTLCreateSystemDefaultDevice();
        [self config];
        [self render];
    }
    return self;
}

#pragma mark -

- (void)config {
    id <MTLLibrary> library = [self.device newDefaultLibrary];
    
    MTLRenderPipelineDescriptor *renderPipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    renderPipelineDescriptor.vertexFunction = [library newFunctionWithName:@"vertexFunc"];
    renderPipelineDescriptor.fragmentFunction = [library newFunctionWithName:@"fragmentFunc"];
    renderPipelineDescriptor.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm;
    self.pipelineState = [self.device newRenderPipelineStateWithDescriptor:renderPipelineDescriptor error:nil];
    
    // 顶点
    float vertexs[] = {
         0.0f,  1.0f, 0.0f, 1.0f,   // 顶部
        -1.0f, -1.0f, 0.0f, 1.0f,   // 下左
         1.0f, -1.0f, 0.0f, 1.0f    // 下右
    };
    self.vertexBuffer = [self.device newBufferWithBytes:vertexs length:sizeof(vertexs) options:MTLResourceStorageModeShared];
}

- (void)render {
    MTLRenderPassDescriptor *rpd = self.currentRenderPassDescriptor;
    rpd.colorAttachments[0].clearColor = MTLClearColorMake(0.0, 0.0, 0.0, 1.0);
    
    id <MTLCommandQueue> commandQueue = [self.device newCommandQueue];
    id <MTLCommandBuffer> commandBuffer = [commandQueue commandBuffer];
    id <MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:rpd];
    
    [encoder setRenderPipelineState:_pipelineState];
    [encoder setVertexBuffer:_vertexBuffer offset:0 atIndex:0];
    
    [encoder drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:3];
    [encoder endEncoding];
    [commandBuffer presentDrawable:self.currentDrawable];
    [commandBuffer commit];
}


@end
