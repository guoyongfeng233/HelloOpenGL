//
//  OpenGLView.m
//  HelloOpenGL
//
//  Created by guoyf on 2018/3/1.
//  Copyright © 2018年 guoyf. All rights reserved.
//

#import "OpenGLView.h"
#import "CC3GLMatrix.h"

//一个用于跟踪所有顶点信息的结构Vertex （目前只包含位置和颜色。）
typedef struct {
    float Position[3]; //位置 x,y,z
    float Color[4];    //颜色 r,g,b,a
    float TexCoords[2];//纹理 x,y   坐标系以左上角为（0，0）
} Vertex;

/*
 TexCoords中的两个数 x,y解释
 一般纹理会使用一张图片，x表示横向的图片数量，如果2，则横向填充会使用两张图片，如果是0.5，则纹理使用时横向只会填充图片的一半
 y表示纵向的图片数量，如果1，则使用1张图片进行填充
 因为opengl只能使用三角形填充，所以填充纹理会跟顶点的顺序有关
 图片  a---------b    填充图像  0----------1
      |         |             |          |
      |         |             |          |
      c---------d             2----------3
   比如顶点顺序为 0，1，2  而对应的纹理坐标为 b,c,d
   那么填充时 0 将对应b点的图像，1将对应c点的图像，2将对应d 点的图像，可能的结果就是三角形填充的图片被切掉或者翻转或者被拉伸
 */


////定义了以Vertex结构为类型的array。
//const Vertex Vertices[] = {
//    {{1, -1, 0}, {1, 0, 0, 1}},
//    {{1, 1, 0}, {0, 1, 0, 1}},
//    {{-1, 1, 0}, {0, 0, 1, 1}},
//    {{-1, -1, 0}, {0, 0, 0, 1}}
//};

////一个用于表示三角形顶点的数组。
//const GLubyte Indices[] = {
//    0, 1, 2,
//    2, 3, 0
//};

#define TEX_COORD_MAX 1  //表示在该方向上的使用的图片的数量

const Vertex Vertices[] = {

    {{1, -1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{1, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {0, 0}},
    {{-1, -1, 0}, {0, 1, 0, 1}, {0, TEX_COORD_MAX}},
    {{1, -1, -2}, {1, 0, 0, 1}, {0, 0}},
    {{1, 1, -2}, {1, 0, 0, 1}, {0, TEX_COORD_MAX}},
    {{-1, 1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},
    {{-1, -1, -2}, {0, 1, 0, 1}, {TEX_COORD_MAX, 0}}
};

const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
    // Back
    4, 6, 5,
    4, 7, 6,
    // Left
    2, 6, 7,
    2, 7, 3,
    // Right
    0, 4, 1,
    4, 1, 5,
   // Top
    6, 2, 1,
    1, 6, 5,
    // Bottom
    0, 3, 7,
    0, 7, 4
};

////立体顶点数组
//const Vertex Vertices[] = {
//
//    {{0, 1, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},              //头
//    {{-0.5, 0.5, 0}, {1, 0, 0, 1}, {0, TEX_COORD_MAX}},         //左上尖
//    {{-0.25, 0.5, 0}, {1, 0, 0, 1}, {0, 0}},        //左上支
//    {{-0.25, -0.5, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, 0}},       //左下支
//    {{-0.5, -0.5, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},        //左下尖
//    {{0, -1, 0}, {0, 1, 0, 1}, {TEX_COORD_MAX, 0}},             //尾
//    {{0.5, -0.5, 0}, {0, 1, 0, 1}, {0, 0}},         //右下尖
//    {{0.25, -0.5, 0}, {0, 1, 0, 1}, {0, TEX_COORD_MAX}},        //右下支
//    {{0.25, 0.5, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},         //右上支
//    {{0.5, 0.5, 0}, {1, 0, 0, 1}, {TEX_COORD_MAX, 0}},          //右上尖
//
//    {{0, 1, -1}, {0, 0, 1, 1}, {0, 0}},              //头
//    {{-0.5, 0.5, -1}, {0, 0, 1, 1}, {TEX_COORD_MAX, 0}},         //左上尖
//    {{-0.25, 0.5, -1}, {0, 0, 1, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},        //左上支
//    {{-0.25, -0.5, -1}, {0, 0.5, 0.2, 1}, {0, TEX_COORD_MAX}},   //左下支
//    {{-0.5, -0.5, -1}, {0, 0.5, 0.2, 1}, {0, 0}},    //左下尖
//    {{0, -1, -1}, {0, 0.5, 0.2, 1}, {0, TEX_COORD_MAX}},         //尾
//    {{0.5, -0.5, -1}, {0, 0.5, 0.2, 1}, {TEX_COORD_MAX, TEX_COORD_MAX}},     //右下尖
//    {{0.25, -0.5, -1}, {0, 0.5, 0.2, 1}, {TEX_COORD_MAX, 0}},    //右下支
//    {{0.25, 0.5, -1}, {0, 0, 1, 1}, {0, 0}},         //右上支
//    {{0.5, 0.5, -1}, {0, 0, 1, 1}, {0, TEX_COORD_MAX}},          //右上尖
//};
//
//const GLubyte Indices[] = {
//    // Front
//    0,1,9,
//    3,2,8,
//    8,3,7,
//    4,5,6,
//    // Back
//    10,11,19,
//    13,12,18,
//    18,13,17,
//    14,15,16,
//    // Left
//    0,1,10,
//    1,10,11,
//    1,2,11,
//    11,12,2,
//    2,3,12,
//    3,12,13,
//    3,4,13,
//    13,14,4,
//    4,5,14,
//    14,15,5,
//    // Right
//    0,9,10,
//    9,10,19,
//    8,9,18,
//    18,19,9,
//    8,7,17,
//    8,17,18,
//    6,7,17,
//    16,17,6,
//    6,5,15,
//    15,16,6,
//
//};



@implementation OpenGLView
{
    CC3Vector4 _vectory4;
}

-(void)updateWithX:(CGFloat)x Y:(CGFloat)y Z:(CGFloat)z W:(CGFloat)w{
    _vectory4 = CC3Vector4Make(x, y, z, w);
}

//加载资源
- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName
                                                           ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath
                                                       encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    //调用 glCreateShader来创建一个代表shader 的OpenGL对象。
    GLuint shaderHandle = glCreateShader(shaderType);
    
    //调用glShaderSource ，让OpenGL获取到这个shader的源代码。
    //这里我们还把NSString转换成C-string
    const char* shaderStringUTF8 = [shaderString UTF8String];
    int shaderStringLength = (int)[shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    //最后，调用glCompileShader 在运行时编译shader
    glCompileShader(shaderHandle);
    
    // glGetShaderiv 和 glGetShaderInfoLog  会把error信息输出到屏幕
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}


- (void)compileShaders {
    
    //1.动态编译方法，分别编译了vertex shader 和 fragment shader
    GLuint vertexShader = [self compileShader:@"SimpleVertex"
                                     withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"SimpleFragment"
                                       withType:GL_FRAGMENT_SHADER];
    
    //2.调用了glCreateProgram glAttachShader  glLinkProgram 连接 vertex 和 fragment shader成一个完整的program。
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    
    //glDetachShader(programHandle, vertexShader); 使用glDetachShader将连接的着色器从项目中分离
    
    glLinkProgram(programHandle);
    
    //3.调用 glGetProgramiv  lglGetProgramInfoLog 来检查是否有error，并输出信息。
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    //4.调用 glUseProgram  让OpenGL真正执行你的program 激活项目
    glUseProgram(programHandle);
    
    //5.最后，调用 glGetAttribLocation 来获取指向 vertex shader传入变量的指针。以后就可以通过这写指针来使用了。还有调用 glEnableVertexAttribArray来启用这些数据
    
    //使用get和bind两种方式获取参数位置
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    
//    _positionSlot = 1;
//    _colorSlot = 2;
//    glBindAttribLocation(programHandle, _positionSlot, "Position");
//    glBindAttribLocation(programHandle, _colorSlot, "SourceColor");
    
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    
    _texCoordSlot = glGetAttribLocation(programHandle, "TexCoordIn");
    _textureUniform = glGetUniformLocation(programHandle, "Texture");
    _lightUniform = glGetUniformLocation(programHandle, "lightMap");
    glEnableVertexAttribArray(_texCoordSlot);
}

//启用定时器
- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupLayer]; //初始化layer
        [self setupContext]; //初始化上下文
        [self setupDepthBuffer]; //初始化深度缓冲
        [self setupRenderBuffer]; //初始化渲染缓冲
        [self setupFrameBuffer];  //初始化帧缓冲
        [self compileShaders];    //加载材质信息
        [self setupVBOs];         //初始化顶点缓存
        
        [self setupDisplayLink];  //开启定时器
        _floorTexture = [self setupTexture:@"0.jpeg"];
        _lightTexture = [self setupTexture:@"0.jpeg"];
    }
    return self;
}

- (void)dealloc
{
    _context = nil;
}

// 读取图像数据宽度文件名
- (GLuint)setupTexture:(NSString *)fileName {
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    CGContextRelease(spriteContext);
    
    GLuint texName;
    //使用glGenTextures获取贴图对象  glGenTexturesshanc 贴图对象
    glGenTextures(1, &texName);
    //glBindTexture绑定贴图对象，应用必须绑定贴图对象才能运行它
    //第一个参数 绑定贴图对象到目标 GL_TEXTURE_2D 或 GL_TEXTURE_CUBE_MAP
    glBindTexture(GL_TEXTURE_2D, texName);
    
//    glGenerateMipmap(GL_CLAMP_TO_EDGE);
    
    /*
        glTexParameter+ i/iv/f/fv 有四个方法 前两个参数相同 GLenum target, GLenum pname 后一个参数为param类型不同
            target      绑定贴图对象的目标GL_TEXTURE_2D或GL_TEXTURE_CUBE_MAP
            pname       设定的参数，可能值是:GL_TEXTURE_MAG_FILTER、GL_TEXTURE_MIN_FILTER、GL_TEXTURE_WRAP_S、GL_TEXTURE_WRAP_T
            param       设定贴图参数的值
                        如果 pname 是 GL_TEXTURE_MAG_FILTER, 那么 param 是: GL_NEAREST、GL_LINEAR
                        如果 pname 是 GL_TEXTURE_MIN_FILTER, 那么 param 是: GL_NEAREST、GL_LINEAR、GL_NEAREST_MIPMAP_NEAREST、GL_NEAREST_MIPMAP_LINEAR、GL_LINEAR_MIPMAP_NEAREST、GL_LINEAR_MIPMAP_LINEAR
                        如果 pname 是 GL_TEXTURE_WRAP_S 或 GL_TEXTURE_WRAP_R, 那么 param 是: GL_REPEAT、GL_CLAMP_TO_EDGE、GL_MIRRORED_REPEAT
     
        GL_NEARESTA 贴图最近的采样点将使用做贴图坐标.
        GL_LINEARA 双线性(四个点平均)采样点作为贴图坐标.
     
     */
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    /*
     glTexImage2D (GLenum target, GLint level, GLint internalformat, GLsizei width, GLsizei height, GLint border, GLenum format, GLenum type, const GLvoid* pixels)
     
        target              指定贴图对象的目标，是 GL_TEXTURE_2D 或着 立方体的一个面(例如, GL_TEXTURE_CUBE_MAP_POSITIVE_X, GL_TEXTURE_CUBE_MAP_NEGATIVE_X, 等等.)
        level               指定装载的水平。基本的水平是 0，对连续的多级纹理水平不断增加
        internalFormat      纹理存储的内部格式，可以是: GL_RGBA、GL_RGB、GL_LUMINANCE_ALPHA、GL_LUMINANCE、GL_ALPHA
        width height        宽高，单位像素
        border              这个参数被忽略，始终为0
        type                传入像素数据的类型，能够是: GL_UNSIGNED_BYTE、GL_UNSIGNED_SHORT_4_4_4_4、GL_UNSIGNED_SHORT_5_5_5_1、GL_UNSIGNED_SHORT_5_6_5
        pixels              实际的像素数据
     */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)width, (GLsizei)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);
    return texName;
}

- (void)setupVBOs {
    
    /*
     两种跟踪顶点信息的缓存类型
        1、跟踪每个顶点信息的
        2、跟踪组成每个三角形的索引信息
     */
    //第一种方式
    GLuint vertexBuffer;
    //glGenBuffers - 创建一个Vertex Buffer 对象  对应删除方法glDeleteBuffers
    glGenBuffers(1, &vertexBuffer); //参数1表示获取几个缓存指针，可以使用数组形式获取多个
    
    //告诉OpenGL我们的vertexBuffer 是指GL_ARRAY_BUFFER
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    
    //glBufferData – 把数据传到OpenGL-land  使用glBufferData初始化缓存数据对象存储  glBufferSubData更新缓冲区对象存储
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    /*
     GL_STATIC_DRAW                 缓冲区对象数据一旦被应用程序指定，多次使用去绘制基元
     GL_DYNAMIC_DRAW                缓冲区对象数据多次被应用程序指定，多次使用去绘制基元
     GL_STREAM_DRAW                 缓冲区对象数据一旦被应用程序指定，很少使用去绘制基元
     */
    
    //第二种方式
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
}


//想要显示OpenGL的内容，你需要把它缺省的layer设置为一个特殊的layer。（CAEAGLLayer）。这里通过直接复写layerClass的方法。
+ (Class)layerClass {
    return [CAEAGLLayer class];
}

//缺省的话，CALayer是透明的。而透明的层对性能负荷很大，特别是OpenGL的层
- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    
    //这里使用了glRenderbufferStorage, 然不是context的renderBufferStorage（这个是在OpenGL的view中特别为color render buffer而设的）
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);
}

//创建OpenGL context
- (void)setupContext {
    
    //当你创建一个context，你要声明你要用哪个version的API。这里，我们选择OpenGL ES 2.0.
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;

    //EAGLContext管理所有通过OpenGL进行draw的信息
    _context = [[EAGLContext alloc] initWithAPI:api];
    
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

//创建render buffer （渲染缓冲区）
- (void)setupRenderBuffer {
    
    /*
     Render buffer 是OpenGL的一个对象，用于存放渲染过的图像。
     
     有时候你会发现render buffer会作为一个color buffer被引用，因为本质上它就是存放用于显示的颜色
     创建render buffer的三步：
     
         1.调用glGenRenderbuffers来创建一个新的render buffer object。这里返回一个唯一的integer来标记render buffer（这里把这个唯一值赋值到_colorRenderBuffer）。有时候你会发现这个唯一值被用来作为程序内的一个OpenGL 的名称。（反正它唯一嘛）
     
         2.调用glBindRenderbuffer ，告诉这个OpenGL：我在后面引用GL_RENDERBUFFER的地方，其实是想用_colorRenderBuffer。其实就是告诉OpenGL，我们定义的buffer对象是属于哪一种OpenGL对象
     
         3.最后，为render buffer分配空间。renderbufferStorage
     */
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
}


//创建一个 frame buffer （帧缓冲区）
- (void)setupFrameBuffer {
    
    /*
     Frame buffer也是OpenGL的对象，它包含了前面提到的render buffer，以及其它后面会讲到的诸如：depth buffer、stencil buffer 和 accumulation buffer。
     
     前两步创建frame buffer的动作跟创建render buffer的动作很类似。（反正也是用一个glBind什么的）
     
     而最后一步  glFramebufferRenderbuffer 这个才有点新意。它让你把前面创建的buffer render依附在frame buffer的GL_COLOR_ATTACHMENT0位置上。
     */
    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER, _colorRenderBuffer);
    
    //将_depthRenderBuffer依附在framebuffer的GL_DEPTH_ATTACHMENT位置上
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

//渲染
- (void)render:(CADisplayLink *)displayLink {
    
   
//     3.调用OpenGL context的presentRenderbuffer方法，把缓冲区（render buffer和color buffer）的颜色呈现到UIView上。
    
    //调用glClearColor ，设置一个RGB颜色和透明度，接下来会用这个颜色涂满全屏。
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    
    //调用glClear来进行这个“填色”的动作 参数声明清理哪一个缓存区 这里是颜色和深度两个缓冲区
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //并启用depth  testing
    glEnable(GL_DEPTH_TEST);
    
    //创建投影矩阵
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    //指定左右上下和远近平面
    /*
     相当于指定摄像头视图范围，左右上下指的是近平面的边位置，远平面会根据距离自己计算比例。
     只能看到远平面和近平面之间的物体。
     物体放入会按近平面比例进行变形
     */
    CGFloat h = self.frame.size.height/self.frame.size.width;
    //四点构成正方向平面,构建投影矩阵
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h*2 andTop:h*2 andNear:2 andFar:10];
    //将矩阵传递到simpleVertex.glsl文件中去
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    /*
     glUniform函数可以加很多类型，glUniform2f表示有两个float类型的参数 如果后面有v，表示要传指针
     如： 不带v的 glUniform4i(GLint location, GLint x, GLint y,GLint z, GLint w)
           带v的 glUniform4iv(GLint location, GLsizei count,const GLint* v)
     
     glUniformMatrix4fv (GLint location, GLsizei count, GLboolean transpose, const GLfloat* value);
     location   赋值常量的位置
     count      赋值数量
     transpose  固定为0
     value      对应类型的指针
     */
    
    //创建变形矩阵
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
//    float x = sin(CACurrentMediaTime());
//    float z = fabs(x)*5.18-8.59;
//
    //设置位移矩阵
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -6)];
//    _currentRotation += displayLink.duration *90;
//    [modelView rotateBy:CC3VectorMake(_currentRotation, _currentRotation, 0)];
    [modelView rotateByQuaternion:_vectory4];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    //1.调用glViewport 设置UIView中用于渲染的部分。这个例子中指定了整个屏幕。但如果你希望用更小的部分，你可以更变这些参数。
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    /*
     glviewport(x,y,w,h)指定渲染窗口
     x,y 指定窗口左下角坐标
     w,h 指定窗口的宽高
     正常设备坐标 (a,b,c) 转到窗口坐标 (e,d,g) 算法
     
     (e,d,g) = (
                    (w/2)*a+j),
                    (h/2)*b+k,
                    (f-n)/2*c+(f+n)/2
                )
     其中      j = (x+w)/2  k = (y+h)/2
              n和f表示深度范围值在 0 - 1间 默认是 0 和 1
              使用glDepthRange函数设置
     */
    
    
    
    
    //纹理相关
    glActiveTexture(GL_TEXTURE0);  //激活贴图单元
    glBindTexture(GL_TEXTURE_2D, _floorTexture);
    glUniform1i(_textureUniform, 0);
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, _lightTexture);
    glUniform1i(_lightUniform, 1);
    /*
     2.调用glVertexAttribPointer来为vertex shader的两个输入参数配置两个合适的值
         ·第一个参数，声明这个属性的名称，之前我们称之为glGetAttribLocation
         ·第二个参数，定义这个属性由多少个值组成。譬如说position是由3个float（x,y,z）组成，而颜色是4个float（r,g,b,a）
         ·第三个，声明每一个值是什么类型。（这例子中无论是位置还是颜色，我们都用了GL_FLOAT）
         ·第四个，嗯……它总是false就好了。
         ·第五个，指 stride 的大小。这是一个种描述每个 vertex数据大小的方式。所以我们可以简单地传入 sizeof（Vertex），让编译器计算出来就好。
         ·最后一个，是这个数据结构的偏移量。表示在这个结构中，从哪里开始获取我们的值。Position的值在前面，所以传0进去就可以了。而颜色是紧接着位置的数据，而position的大小是3个float的大小，所以是从 3 * sizeof(float) 开始的。
     */
    
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE,
                          sizeof(Vertex), (GLvoid*) (sizeof(float) *3));
    glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)(sizeof(float) * 7));
   
    /*
     3.调用glDrawElements ，它最后会在每个vertex上调用我们的vertex shader，以及每个像素调用fragment shader，最终画出我们的矩形。
         ·第一个参数，声明用哪种特性来渲染图形。有GL_LINE_STRIP 和 GL_TRIANGLE_FAN。然而GL_TRIANGLE是最常用的，特别是与VBO 关联的时候。
         ·第二个，告诉渲染器有多少个图形要渲染。我们用到C的代码来计算出有多少个。这里是通过个 array的byte大小除以一个Indice类型的大小得到的。
         ·第三个，指每个indices中的index类型
         ·最后一个，在官方文档中说，它是一个指向index的指针。但在这里，我们用的是VBO，所以通过index的array就可以访问到了（在GL_ELEMENT_ARRAY_BUFFER传过了），所以这里不需要.
     */
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]),
                   GL_UNSIGNED_BYTE, 0);
    
    /* 另一种绘图
     第一个参数 mode 可选项有
     GL_POINTS                              画点
     #define GL_LINES                       相邻两点相连 0-1 2-3 4-5
     #define GL_LINE_LOOP                   按数组顺序从头到尾连线并闭合 0-1-2-3-4-0
     #define GL_LINE_STRIP                  按数组顺序从头到尾连线不闭合 0-1-2-3-4
     #define GL_TRIANGLES                   三角形 0-1-2 3-4-5
     #define GL_TRIANGLE_STRIP              相邻3点连三角形，三角形相邻 0-1-2 1-2-3 2-3-4
     #define GL_TRIANGLE_FAN                以一个点为顶点，连接其余的相邻两点组成三角形 0-1-2 0-2-3 0-3-4
     glDrawArrays(GLenum mode, GLint first, GLsizei count)

     注：有些情况下不得不在顶点序列中出现很多重复的顶点,若希望减少重复顶点占用的空间,可考虑
     采用glDrawElements方法来进行物体的绘制. 该方法需要传入顶点索引数组
     
     */
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
    
    
    
}



@end
