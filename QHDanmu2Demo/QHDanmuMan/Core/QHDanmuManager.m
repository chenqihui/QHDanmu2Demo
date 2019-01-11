//
//  QHDanmuManager.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/10.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuManager.h"

#import "NSTimer+QHEOCBlocksSupport.h"
#import "QHDanmuView.h"

@interface QHDanmuManager ()

@property (nonatomic, strong) NSTimer *managerTimer;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *danmuDataList;

@property (nonatomic, weak) QHDanmuView *danmuView;

@end

@implementation QHDanmuManager

- (void)dealloc {
#if DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    [self p_closeTimer];
    _danmuDataList = nil;
    _startTimeBlock = nil;
}

#pragma mark - Public

- (instancetype)initWithDanmuView:(QHDanmuView *)danmuView {
    self = [super init];
    if (self) {
        _danmuDataList = [NSMutableArray new];
        _danmuView = danmuView;
        _mediaPlayAbsoluteTime = 0;
        _startTimeBlock = ^CFTimeInterval(NSDictionary *data) {
            return 0;
        };
    }
    return self;
}

- (void)addDanmu:(NSArray<NSDictionary *> *)data {
    if (data == nil || data.count <= 0) {
        return;
    }
    NSArray *dataTemp = [data sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        CFTimeInterval v1 = self.startTimeBlock(obj1);
        CFTimeInterval v2 = self.startTimeBlock(obj2);
        
        NSComparisonResult result = v1 <= v2 ? NSOrderedAscending : NSOrderedDescending;
        
        return result;
    }];
    
    // ??? 已有的也得进行排序
//    [_danmuDataList addObjectsFromArray:dataTemp];
    
    _danmuDataList = [self insertSort:_danmuDataList secondArray:dataTemp];
}

- (void)insertDanmu:(NSDictionary *)data {
    [_danmuView insertDataInFirst:data];
}

- (void)setMediaPlayAbsoluteTime:(CFAbsoluteTime)mediaPlayAbsoluteTime {
    _mediaPlayAbsoluteTime = mediaPlayAbsoluteTime;
    int index = -1;
    if (_danmuDataList.count > 0) {
        for (int i = 0; i < _danmuDataList.count; i++) {
            NSDictionary *danmuData = _danmuDataList[i];
            CFTimeInterval startTime = 0;
            startTime = _startTimeBlock(danmuData);
            
            if (startTime <= mediaPlayAbsoluteTime) {
                index = i;
            }
            else {
                break;
            }
        }
        if (index >= 0) {
            NSArray *inData = [_danmuDataList subarrayWithRange:NSMakeRange(0, index + 1)];
            [_danmuView insertData:inData];
            [_danmuDataList removeObjectsInArray:inData];
        }
    }
}

- (void)start {
    [_danmuView start];
}

- (void)stop {
    [_danmuDataList removeAllObjects];
    [_danmuView cleanData];
}

- (void)resume {
    [_danmuView resume];
}

- (void)pause {
    [_danmuView pause];
}

#pragma mark - Private

- (void)p_closeTimer {
    [_managerTimer invalidate];
    _managerTimer = nil;
}

#pragma mark - Util

// [iOS算法总结-归并排序 - 简书](https://www.jianshu.com/p/04d9480a0633)
- (NSMutableArray<NSDictionary *> *)insertSort:(NSArray<NSDictionary *> *)firstArray secondArray:(NSArray<NSDictionary *> *)secondArray{
    NSMutableArray *resultArray = [NSMutableArray array];
    NSInteger firstIndex = 0, secondIndex = 0;
    while (firstIndex < firstArray.count && secondIndex < secondArray.count) {
        if ([firstArray[firstIndex][@"v"] doubleValue] < [secondArray[secondIndex][@"v"] doubleValue]) {
            [resultArray addObject:firstArray[firstIndex]];
            firstIndex++;
        } else {
            [resultArray addObject:secondArray[secondIndex]];
            secondIndex++;
        }
    }
    while (firstIndex < firstArray.count) {
        [resultArray addObject:firstArray[firstIndex]];
        firstIndex++;
    }
    while (secondIndex < secondArray.count) {
        [resultArray addObject:secondArray[secondIndex]];
        secondIndex++;
    }
    return resultArray;
}

@end
