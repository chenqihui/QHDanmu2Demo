//
//  QHTableSubViewController+SLCDanmu.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/8.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHTableSubViewController+SLCDanmu.h"

#import "QHViewUtil.h"
#import "SLCDanmuViewCell.h"
#import "QHBaseUtil.h"

@implementation QHTableSubViewController (SLCDanmu)

// [警告: Category is implementing a method which will also be implemented by its primary class - DCSnail-蜗牛 - CSDN博客](https://blog.csdn.net/wangyanchang21/article/details/69230294)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

#pragma mark - QHDanmuViewDataSource

- (NSInteger)numberOfPathwaysInDanmuView:(QHDanmuView * _Nonnull)danmuView forAnimationSection:(NSInteger)section {
    return 2;
}

- (CGFloat)heightOfPathwayCellInDanmuView:(QHDanmuView * _Nonnull)danmuView forAnimationSection:(NSInteger)section {
    return kSLCDanmuViewCellHeight;
}

// ??? 避免两次转换 NSAttributedString
- (QHDanmuViewCell * _Nullable)danmuView:(QHDanmuView * _Nonnull)danmuView cellForPathwayWithData:(NSDictionary * _Nonnull)data forAnimationSection:(NSInteger)section {
    SLCDanmuViewCell *cell = [danmuView dequeueReusableCellWithIdentifier:kSLCDanmuViewCellContentIdentifier];
    cell.contentTextLabel.attributedText = [QHTableSubViewController toSay:data];
    return cell;
}

#pragma mark - QHDanmuViewDelegate

- (CGFloat)danmuView:(QHDanmuView * _Nonnull)danmuView widthForPathwayWithData:(NSDictionary * _Nonnull)data forAnimationSection:(NSInteger)section {
    NSAttributedString *c = [QHTableSubViewController toSay:data];
    CGFloat w = c.size.width + kSLCDanmuViewCellEdgeInsets.left + kSLCDanmuViewCellEdgeInsets.right;
    return w;
}

#pragma clang diagnostic pop

+ (NSMutableAttributedString *)toSay:(NSDictionary *)data {
    NSDictionary *body = data[@"body"];
    NSString *n = body[@"n"];
    NSString *c = body[@"c"];
    NSString *contentString = [NSString stringWithFormat:@"<font color='#CCCCCC'>%@：</font><font color='#FFFFFF'>%@</font>", n, c];
    NSMutableAttributedString *chatData = [NSMutableAttributedString new];
    [chatData appendAttributedString:[QHBaseUtil toHTML:contentString fontSize:13]];
    
    return chatData;
}

@end
