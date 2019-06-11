//
//  QHAIDanmuViewController.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/5/16.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHAIDanmuViewController.h"

#import "QHDanmuView.h"
#import "QHViewUtil.h"
#import "QHBaseUtil.h"
#import "NSTimer+QHEOCBlocksSupport.h"

@interface QHAIDanmuViewController () <QHDanmuViewDataSource, QHDanmuViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *showMainV;

@property (nonatomic, strong) QHDanmuView *danmuView;
@property (nonatomic, strong) NSTimer *aiFaceTimer;
@property (nonatomic) NSInteger faceIn;

@property (weak, nonatomic) IBOutlet UIView *testV;

@end

@implementation QHAIDanmuViewController

- (void)dealloc {
    [_aiFaceTimer invalidate];
    _aiFaceTimer = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _faceIn = 0;
    
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    danmuView.danmuPoolMaxCount = 20;
    danmuView.searchPathwayMode = QHDanmuViewSearchPathwayModeBreadthFirst;
    [_showMainV addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[QHDanmuViewCell class] forCellReuseIdentifier:@"1"];
    _danmuView = danmuView;
    
    [self p_addPersonMask5];
//    [self p_goAIFaceTimer];
    
    
}

#pragma mark - Private

/*
 * [CAGradientLayer的一些属性解析 - YouXianMing - 博客园](http://www.cnblogs.com/YouXianMing/p/3793913.html)
 * [利用CAShapeLayer和UIBezierPath实现中空透明圆，圆外填充色 - Carl-w - CSDN博客](https://blog.csdn.net/w_x_p/article/details/50553342)
 * [使用maskView设计动画及遮盖 | Cowboy Tech](http://jackliu17.github.io/2016/05/03/%E4%BD%BF%E7%94%A8maskView%E8%AE%BE%E8%AE%A1%E5%8A%A8%E7%94%BB%E5%8F%8A%E9%81%AE%E7%9B%96/)
 
 * [一行代码实现 UIView 镂空效果 | Lyman's Blog](http://www.lymanli.com/2018/11/10/subtract-mask/)
 * [Quartz 2D编程指南之十一：位图与图像遮罩 | 南峰子的技术博客](http://southpeak.github.io/2015/01/05/quartz2d-11/)
 * [Cowboy Tech](http://jackliu17.github.io/page/17/)
 */
- (void)p_addAIMask {
    UIView *containerView = [[UIView alloc] initWithFrame:_showMainV.bounds];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame            = containerView.bounds;
    gradientLayer.colors           = @[(__bridge id)[UIColor blackColor].CGColor,
                                       (__bridge id)[UIColor clearColor].CGColor,
                                       (__bridge id)[UIColor clearColor].CGColor,
                                       (__bridge id)[UIColor blackColor].CGColor];
    gradientLayer.locations        = @[@(0.25), @(0.3), @(0.7), @(0.75)];
//    gradientLayer.colors           = @[(__bridge id)[UIColor blackColor].CGColor,
//                                       (__bridge id)[UIColor blackColor].CGColor];
//    gradientLayer.locations        = @[@(0.25), @(0.75)];
    gradientLayer.startPoint       = CGPointMake(0, 0);
    gradientLayer.endPoint         = CGPointMake(1, 0);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGFloat ssX = 60;
    CGFloat ssY = 20;
    CGFloat centerX = _showMainV.frame.size.width/2 + (ssX * _faceIn);
    CGFloat centerY = _showMainV.frame.size.height/2 + (ssY * _faceIn);
    CGFloat radius = _showMainV.frame.size.height/2 - 40;
    CGFloat spaceL = centerX;
    CGFloat spaceR = _showMainV.frame.size.width - centerX;
    CGFloat spaceT = centerY;
    CGFloat spaceB = _showMainV.frame.size.height - centerY;
    
    UIBezierPath *bezierpath = [UIBezierPath bezierPath];
    [bezierpath moveToPoint:CGPointMake(centerX + radius, centerY)];
    [bezierpath addCurveToPoint:CGPointMake(centerX, centerY - radius) controlPoint1:CGPointMake(centerX + radius, centerY) controlPoint2:CGPointMake(centerX + radius, centerY - radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX - radius, centerY) controlPoint1:CGPointMake(centerX, centerY - radius) controlPoint2:CGPointMake(centerX - radius, centerY - radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX, centerY + radius) controlPoint1:CGPointMake(centerX - radius, centerY) controlPoint2:CGPointMake(centerX - radius, centerY + radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX + radius, centerY - 0.00001) controlPoint1:CGPointMake(centerX, centerY + radius) controlPoint2:CGPointMake(centerX + radius, centerY + radius)];
    
    [bezierpath addLineToPoint:CGPointMake(centerX + spaceR, centerY - 0.00001)];
    [bezierpath addLineToPoint:CGPointMake(centerX + spaceR, centerY + spaceB)];
    [bezierpath addLineToPoint:CGPointMake(centerX - spaceL, centerY + spaceB)];
    [bezierpath addLineToPoint:CGPointMake(centerX - spaceL, centerY - spaceT)];
    [bezierpath addLineToPoint:CGPointMake(centerX + spaceR, centerY - spaceT)];
    [bezierpath addLineToPoint:CGPointMake(centerX + spaceR, centerY - 0.00001)];
    
    bezierpath.lineWidth = 0;
    [bezierpath closePath];
    shapeLayer.path = bezierpath.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
//    gradientLayer.mask = shapeLayer;
    
    containerView.layer.mask = shapeLayer;
//    [containerView.layer addSublayer:shapeLayer];
    [containerView.layer addSublayer:gradientLayer];
    
    _showMainV.maskView = containerView;
}

- (void)p_goAIFaceTimer {
    if (_aiFaceTimer == nil) {
        __weak typeof(self) weakSelf = self;
        _aiFaceTimer = [NSTimer qheoc_scheduledTimerWithTimeInterval:1 block:^{
            [weakSelf p_changeFaceIn];
        } repeats:YES];
    }
}

- (void)p_changeFaceIn {
    _faceIn++;
    if (_faceIn > 2) {
        _faceIn = -1;
    }
    [self p_addAIMask];
}

- (void)p_addPersonMask {
    UIView *containerView = [[UIView alloc] initWithFrame:_showMainV.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    UIBezierPath *bezierpath = [UIBezierPath bezierPath];

    CGFloat w = _showMainV.frame.size.width;
    CGFloat h = _showMainV.frame.size.height;
    CGFloat www = 30;
    CGFloat hh = h/7;
    CGFloat x = w/2 - www;
    CGFloat y = hh * 2;

    NSArray *points = @[@[@(x), @(y)], @[@(x), @(y + hh)],
                        @[@(x - www), @(y + hh)], @[@(x - www), @(y + hh * 2)],
                        @[@(x - www * 2), @(y + hh * 2)], @[@(x - www * 2), @(y + hh * 3)],
                        @[@(x + www * 4), @(y + hh * 3)], @[@(x + www * 4), @(y + hh * 2)],
                        @[@(x + www * 3), @(y + hh * 2)], @[@(x + www * 3), @(y + hh)],
                        @[@(x + www * 2), @(y + hh)], @[@(x + www * 2), @(y)],
                        @[@(x + 0.00001), @(y)], @[@(x + 0.00001), @(0)],
                        @[@(w), @(0)], @[@(w), @(h)],
                        @[@(0), @(h)], @[@(0), @(0)],
                        @[@(x), @(0)]/*, @[@(x), @(y)]*/];

    for (int i = 0; i < points.count; i++) {
        NSArray *point = points[i];
        CGFloat xx = [point[0] floatValue];
        CGFloat yy = [point[1] floatValue];
        if (i == 0) {
            [bezierpath moveToPoint:CGPointMake(xx, yy)];
        }
        else {
            [bezierpath addLineToPoint:CGPointMake(xx, yy)];
        }
    }

    bezierpath.lineWidth = 1;
    [bezierpath closePath];
    shapeLayer.path = bezierpath.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    
    [_showMainV.layer setMask:shapeLayer];
//    [containerView.layer addSublayer:shapeLayer];
//    _showMainV.maskView = containerView;
//    [_showMainV addSubview:containerView];
    
    NSArray *pointGLefts = @[
                             @[@(x - www), @(y)],
                             @[@(x - www * 2), @(y + hh)],
                             @[@(x - www * 3), @(y + hh *2)],
                         ];
    NSArray *pointGRights = @[
                             @[@(x + www * 2), @(y)],
                             @[@(x + www * 3), @(y + hh)],
                             @[@(x + www * 4), @(y + hh * 2)],
                             ];
    
    for (int i = 0; i < pointGLefts.count; i++) {
        NSArray *point = pointGLefts[i];
        CGFloat xx = [point[0] floatValue];
        CGFloat yy = [point[1] floatValue];
        
        UIView *cc = [[UIView alloc] initWithFrame:CGRectMake(xx, yy, www, hh)];
        UIView *c = [[UIView alloc] initWithFrame:CGRectMake(0, 0, www, hh)];
        
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame            = c.bounds;
        gradientLayer.colors           = @[(__bridge id)[UIColor clearColor].CGColor,
                                           (__bridge id)[UIColor blackColor].CGColor];
        gradientLayer.locations        = @[@(0), @(1)];
        gradientLayer.startPoint       = CGPointMake(1, 0);
        gradientLayer.endPoint         = CGPointMake(0, 0);
        
//        c.layer.mask = gradientLayer;
        [c.layer addSublayer:gradientLayer];
        
//        [cc.layer addSublayer:c.layer];
        cc.maskView = c;
        [_showMainV.layer addSublayer:cc.layer];
    }
    for (int i = 0; i < pointGRights.count; i++) {
        NSArray *point = pointGRights[i];
        CGFloat xx = [point[0] floatValue];
        CGFloat yy = [point[1] floatValue];
        CAGradientLayer *gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame            = CGRectMake(xx, yy, www, hh);
        gradientLayer.colors           = @[(__bridge id)[UIColor clearColor].CGColor,
                                           (__bridge id)[UIColor blackColor].CGColor];
        gradientLayer.locations        = @[@(0), @(1)];
        gradientLayer.startPoint       = CGPointMake(0, 0);
        gradientLayer.endPoint         = CGPointMake(1, 0);
        [_showMainV.layer addSublayer:gradientLayer];
    }
}

- (void)p_addPersonMask2 {
    UIView *containerView = [[UIView alloc] initWithFrame:_showMainV.bounds];
    CAGradientLayer *gradientLayer1 = [CAGradientLayer layer];
    gradientLayer1.frame            = containerView.bounds;
    gradientLayer1.colors           = @[(__bridge id)[UIColor blackColor].CGColor,
                                       (__bridge id)[UIColor blackColor].CGColor];
    gradientLayer1.locations        = @[@(0), @(1)];
    gradientLayer1.startPoint       = CGPointMake(0, 0);
    gradientLayer1.endPoint         = CGPointMake(1, 0);
    
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame            = CGRectMake(200, 100, 200, 100);
    gradientLayer.colors           = @[(__bridge id)[UIColor clearColor].CGColor,
                                       (__bridge id)[UIColor blackColor].CGColor];
    gradientLayer.locations        = @[@(0), @(1)];
    gradientLayer.startPoint       = CGPointMake(0, 0);
    gradientLayer.endPoint         = CGPointMake(1, 0);
    
    //    gradientLayer.mask = shapeLayer;
    
//    containerView.layer.mask = shapeLayer;
    //    [containerView.layer addSublayer:shapeLayer];
    
    [containerView.layer addSublayer:gradientLayer];
    [containerView.layer addSublayer:gradientLayer1];
//    containerView.layer.mask = gradientLayer;
    
    _showMainV.maskView = containerView;
//    [_showMainV.layer addSublayer:containerView.layer];
}

- (void)p_addPersonMask3 {
    QHMaskView *m = [[QHMaskView alloc] initWithFrame:_testV.bounds];
//    _testV.maskView = m;
    [_testV addSubview:m];
}

/*
 * [iOS实现UIView渐变的几种方法以及实现渐变透明功能 - u013602835的专栏 - CSDN博客](https://blog.csdn.net/u013602835/article/details/53032684)
 * [iOS CAShapeLayer的FillRule属性总结 - rpf的博客 - CSDN博客](https://blog.csdn.net/rpf2014/article/details/65633306)
 */
- (void)p_addPersonMask4 {
    //创建CGContextRef
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGContextRef gc = UIGraphicsGetCurrentContext();
    
    //创建CGMutablePathRef
    CGMutablePathRef path = CGPathCreateMutable();
    
    //绘制Path
    CGRect rect = _showMainV.bounds;
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(rect), CGRectGetMaxY(rect));
    CGPathAddLineToPoint(path, NULL, CGRectGetWidth(rect), CGRectGetMinY(rect));
    CGPathCloseSubpath(path);
    
    //绘制渐变
    [self drawRadialGradient:gc path:path startColor:[UIColor clearColor].CGColor endColor:[UIColor blackColor].CGColor];
    
    //注意释放CGMutablePathRef
    CGPathRelease(path);
    
    //从Context中获取图像，并显示在界面上
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:img];
//    _showMainV.maskView = imgView;
    [_showMainV.layer setMask:imgView.layer];
}

- (void)drawRadialGradient:(CGContextRef)context
                      path:(CGPathRef)path
                startColor:(CGColorRef)startColor
                  endColor:(CGColorRef)endColor
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.3, 0.6 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    
    CGRect pathRect = CGPathGetBoundingBox(path);
    CGPoint center = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMidY(pathRect));
    CGFloat radius = MAX(pathRect.size.width / 2.0, pathRect.size.height / 2.0) * sqrt(2);
    
    CGContextSaveGState(context);
    CGContextAddPath(context, path);
    CGContextEOClip(context);
    
    CGContextDrawRadialGradient(context, gradient, center, 0, center, radius, 0);
    
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

- (void)p_addPersonMask5 {
    UIImageView *i = [[UIImageView alloc] initWithFrame:_showMainV.bounds];
    i.backgroundColor = [UIColor clearColor];
    i.image = [UIImage imageNamed:@"img.png"];
    i.contentMode = UIViewContentModeScaleAspectFill;
    _showMainV.maskView = i;
//    [_showMainV addSubview:i];
}

/*
 * [IOS实现碎片化动画详解_IOS_脚本之家](https://m.jb51.net/article/90384.htm)
 */
- (void)p_addPersonMask6 {
    UIView *v = [[UIView alloc] initWithFrame:_showMainV.bounds];
//    v.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    sv.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [v addSubview:sv];
    
    _showMainV.maskView = v;
}

#pragma mark - QHDanmuViewDataSource

- (NSInteger)numberOfPathwaysInDanmuView:(QHDanmuView *)danmuView {
    CGSize size = [QHBaseUtil getSizeWithString:@"陈" fontSize:15];
    NSInteger count = _showMainV.frame.size.height / size.height;
    return count;
}

- (CGFloat)heightOfPathwayCellInDanmuView:(QHDanmuView *)danmuView {
    CGSize size = [QHBaseUtil getSizeWithString:@"陈" fontSize:15];
    return size.height;
}

- (QHDanmuViewCell *)danmuView:(QHDanmuView *)danmuView cellForPathwayWithData:(NSDictionary *)data {
    QHDanmuViewCell *cell = [danmuView dequeueReusableCellWithIdentifier:@"1"];
    cell.textLabel.attributedText = [QHBaseUtil toHTML:data[@"c"] fontSize:15];
    return cell;
}

#pragma mark - QHDanmuViewDelegate

- (CGFloat)danmuView:(QHDanmuView *)danmuView widthForPathwayWithData:(NSDictionary *)data {
    NSAttributedString *c = [QHBaseUtil toHTML:data[@"c"] fontSize:15];
    return c.size.width;
}

#pragma mark - Action

- (IBAction)sendAction:(id)sender {
    [_danmuView insertData:@[@{@"n": @"小白1", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白2", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白3", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白4", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白5", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白6", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白7", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白8", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白9", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白10", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白11", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白12", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白13", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白14", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白15", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白16", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白17", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白18", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白19", @"c": @"讲得挺好，一听就明白。"}]];
}

@end

@implementation QHMaskView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    //中间镂空的矩形框
    CGRect myRect =CGRectMake(100,100,200, 200);
    
    //背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:0];
    //镂空
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:myRect];
    [path appendPath:circlePath];
    [path setUsesEvenOddFillRule:YES];
    
    CAShapeLayer *fillLayer = [CAShapeLayer layer];
    fillLayer.path = path.CGPath;
    fillLayer.fillRule = kCAFillRuleEvenOdd;
    fillLayer.fillColor = [UIColor whiteColor].CGColor;
    fillLayer.opacity = 0.5;
    [self.layer addSublayer:fillLayer];
}

@end
