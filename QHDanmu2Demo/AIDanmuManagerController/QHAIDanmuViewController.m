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

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    QHDanmuView *danmuView = [[QHDanmuView alloc] initWithFrame:CGRectZero style:QHDanmuViewStyleCustom];
    danmuView.dataSource = self;
    danmuView.delegate = self;
    danmuView.danmuPoolMaxCount = 20;
    danmuView.searchPathwayMode = QHDanmuViewSearchPathwayModeBreadthFirst;
    [_showMainV addSubview:danmuView];
    [QHViewUtil fullScreen:danmuView];
    [danmuView registerClass:[QHDanmuViewCell class] forCellReuseIdentifier:@"1"];
    _danmuView = danmuView;
    
    [self p_addAIMask];
}

#pragma mark - Private

- (void)p_addAIMask {
    UIView *containerView = [[UIView alloc] initWithFrame:_showMainV.bounds];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame            = containerView.bounds;
//    gradientLayer.colors           = @[(__bridge id)[UIColor blackColor].CGColor,
//                                       (__bridge id)[UIColor clearColor].CGColor,
//                                       (__bridge id)[UIColor clearColor].CGColor,
//                                       (__bridge id)[UIColor blackColor].CGColor];
//    gradientLayer.locations        = @[@(0.25), @(0.3), @(0.7), @(0.75)];
    gradientLayer.colors           = @[(__bridge id)[UIColor blackColor].CGColor,
                                       (__bridge id)[UIColor blackColor].CGColor];
    gradientLayer.locations        = @[@(0.25), @(0.75)];
    gradientLayer.startPoint       = CGPointMake(0, 0);
    gradientLayer.endPoint         = CGPointMake(1, 0);
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    CGFloat radiusW = _showMainV.frame.size.width/2;
    CGFloat radiusH = _showMainV.frame.size.height/2;
    CGFloat centerX = radiusW;
    CGFloat centerY = radiusH;
    CGFloat radius = _showMainV.frame.size.height/2 - 40;
    
    UIBezierPath *bezierpath = [UIBezierPath bezierPath];
    [bezierpath moveToPoint:CGPointMake(centerX + radius, centerY)];
    [bezierpath addCurveToPoint:CGPointMake(centerX, centerY - radius) controlPoint1:CGPointMake(centerX + radius, centerY) controlPoint2:CGPointMake(centerX + radius, centerY - radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX - radius, centerY) controlPoint1:CGPointMake(centerX, centerY - radius) controlPoint2:CGPointMake(centerX - radius, centerY - radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX, centerY + radius) controlPoint1:CGPointMake(centerX - radius, centerY) controlPoint2:CGPointMake(centerX - radius, centerY + radius)];
    [bezierpath addCurveToPoint:CGPointMake(centerX + radius, centerY - 0.00001) controlPoint1:CGPointMake(centerX, centerY + radius) controlPoint2:CGPointMake(centerX + radius, centerY + radius)];
    
    [bezierpath addLineToPoint:CGPointMake(centerX + radiusW, centerY - 0.00001)];
    [bezierpath addLineToPoint:CGPointMake(centerX + radiusW, centerY + radiusH)];
    [bezierpath addLineToPoint:CGPointMake(centerX - radiusW, centerY + radiusH)];
    [bezierpath addLineToPoint:CGPointMake(centerX - radiusW, centerY - radiusH)];
    [bezierpath addLineToPoint:CGPointMake(centerX + radiusW, centerY - radiusH)];
    [bezierpath addLineToPoint:CGPointMake(centerX + radiusW, centerY - 0.00001)];
    
    bezierpath.lineWidth = 0;
    [bezierpath closePath];
    shapeLayer.path = bezierpath.CGPath;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    gradientLayer.mask = shapeLayer;
    
    [containerView.layer addSublayer:gradientLayer];
    
    _danmuView.maskView = containerView;
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
