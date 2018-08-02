//
//  ViewController.m
//  GLKit_00_triangle
//
//  Created by ZHK on 2018/8/2.
//  Copyright © 2018年 ZHK. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <GLKViewDelegate>

@property (nonatomic, strong) EAGLContext   *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self config];
    [self vertexs];
}

- (void)config {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];    // 使用 OpenGL ES 3
    if (_context == nil) {
        NSLog(@"Failed to create ES context");
        return;
    }
    GLKView *view = (GLKView *)self.view;
    view.delegate = self;
    view.context = _context;
    view.drawableColorFormat = GLKViewDrawableColorFormatSRGBA8888;
    
    [EAGLContext setCurrentContext:_context];
    glClearColor(0.1, 0.2, 0.3, 1.0);
    
    self.effect = [[GLKBaseEffect alloc] init];
}

- (void)vertexs {
    // 顶点
    GLfloat vertexs[] = {
         0.0f,  1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f,   // 顶部
        -1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f,   // 下左
         1.0f, -1.0f, 0.0f, 1.0f, 1.0f, 1.0f, 1.0f    // 下右
    };
    
    GLuint buffer;
    glGenBuffers(1, &buffer);
    glBindBuffer(GL_ARRAY_BUFFER, buffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertexs), vertexs, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, (GLfloat *)NULL + 0);
    
    glEnableVertexAttribArray(GLKVertexAttribColor);
    glVertexAttribPointer(GLKVertexAttribColor, 4, GL_FLOAT, GL_FALSE, sizeof(GLfloat) * 7, (GLfloat *)NULL + 3);
    glClearColor(0.1, 0.2, 0.3, 1.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.5, 0.5, 0.5, 1.0);
    [_effect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

@end
