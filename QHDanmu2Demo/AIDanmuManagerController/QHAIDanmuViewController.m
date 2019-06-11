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

@interface QHAIDanmuViewController () <QHDanmuViewDataSource, QHDanmuViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *showMainV;

@property (nonatomic, strong) QHDanmuView *danmuView;

@end

@implementation QHAIDanmuViewController

- (void)dealloc {
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    danmuView.danmuPoolMaxCount = 30;
    danmuView.searchPathwayMode = QHDanmuViewSearchPathwayModeBreadthFirst;
    [_showMainV addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[QHDanmuViewCell class] forCellReuseIdentifier:@"1"];
    _danmuView = danmuView;
    
    [self p_addCAGradientLayer];
}

#pragma mark - Private

// [CAGradientLayer的一些属性解析 - YouXianMing - 博客园](https://www.cnblogs.com/YouXianMing/p/3793913.html)
- (void)p_addCAGradientLayer {
    CAGradientLayer *colorLayer = [CAGradientLayer layer];
    colorLayer.frame    = _showMainV.bounds;
    
    colorLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor,
                          (__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                          (__bridge id)[UIColor colorWithWhite:0 alpha:0].CGColor,
                          (__bridge id)[UIColor colorWithWhite:0 alpha:1].CGColor];
    colorLayer.locations  = @[@(0.25), @(0.4), @(0.6), @(0.75)];
    colorLayer.startPoint = CGPointMake(0, 0);
    colorLayer.endPoint   = CGPointMake(1, 0);
    _showMainV.layer.mask = colorLayer;
}

// [利用CAShapeLayer和UIBezierPath实现中空透明圆，圆外填充色 - Carl-w - CSDN博客](https://blog.csdn.net/w_x_p/article/details/50553342)
// [UIView中间透明周围半透明(四种方法) - zhz459880251的博客 - CSDN博客](https://blog.csdn.net/zhz459880251/article/details/50035631)
- (void)p_addCAShapeLayer {
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
}

/*
 * [IOS实现碎片化动画详解_IOS_脚本之家](https://m.jb51.net/article/90384.htm)
 */
- (void)p_addUIView {
    UIView *v = [[UIView alloc] initWithFrame:_showMainV.bounds];
    v.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
    
    UIView *sv = [[UIView alloc] initWithFrame:CGRectMake(50, 50, 50, 50)];
    sv.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
    [v addSubview:sv];
    
    _showMainV.maskView = v;
}

/*
 * [iOS实现UIView渐变的几种方法以及实现渐变透明功能 - u013602835的专栏 - CSDN博客](https://blog.csdn.net/u013602835/article/details/53032684)
 * [iOS CAShapeLayer的FillRule属性总结 - rpf的博客 - CSDN博客](https://blog.csdn.net/rpf2014/article/details/65633306)
 */
- (void)p_addCGGradientRefImage {
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

// [使用maskView设计动画及遮盖 | Cowboy Tech](http://jackliu17.github.io/2016/05/03/%E4%BD%BF%E7%94%A8maskView%E8%AE%BE%E8%AE%A1%E5%8A%A8%E7%94%BB%E5%8F%8A%E9%81%AE%E7%9B%96/)
- (void)p_addAlphaUIImage {
    UIImageView *i = [[UIImageView alloc] initWithFrame:_showMainV.bounds];
    i.backgroundColor = [UIColor clearColor];
    i.image = [UIImage imageNamed:@"QHAlphaUIImage.png"];
    i.contentMode = UIViewContentModeScaleAspectFill;
    _showMainV.maskView = i;
}

// [一行代码实现 UIView 镂空效果 | Lyman's Blog](http://www.lymanli.com/2018/11/10/subtract-mask/)
- (void)p_addCustomUIImage {
    
}

// [Quartz 2D编程指南之十一：位图与图像遮罩 | 南峰子的技术博客](http://southpeak.github.io/2015/01/05/quartz2d-11/)
// [iOS实现图像指定区域模糊 - ForrestWoo - 博客园](https://www.cnblogs.com/salam/p/5145699.html)

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
                             @{@"n": @"小白19", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白20", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白21", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白22", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白23", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白24", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白25", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白26", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白27", @"c": @"讲得挺好，一听就明白。"},
                             @{@"n": @"小白28", @"c": @"讲得挺好，一听就明白。"}]];
}

#pragma mark - Action

- (IBAction)selectModeAction:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            [self p_addCAGradientLayer];
            break;
        case 1:
            [self p_addCAShapeLayer];
            break;
        case 2:
            [self p_addUIView];
            break;
        case 3:
            [self p_addCGGradientRefImage];
            break;
        case 4:
            [self p_addAlphaUIImage];
            break;
        case 5:
            [self p_addCustomUIImage];
            break;
        default:
            break;
    }
}


@end
