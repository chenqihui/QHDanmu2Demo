//
//  QHDanmuView.m
//  QHDanmu2Demo
//
//  Created by Anakin chen on 2019/1/4.
//  Copyright © 2019 Chen Network Technology. All rights reserved.
//

#import "QHDanmuView.h"

#import "NSTimer+QHEOCBlocksSupport.h"
#import "QHViewUtil.h"

// [UITableView的Cell复用原理和源码分析 - 简书](https://www.jianshu.com/p/5b0e1ca9b673)
// [Chameleon/UITableView.m at master · BigZaphod/Chameleon](https://github.com/BigZaphod/Chameleon/blob/master/UIKit/Classes/UITableView.m)

// [【iOS开发】结构体如何存入数组中 - wm9028的专栏 - CSDN博客](https://blog.csdn.net/wm9028/article/details/50681773)
struct QHDanmuCellParam {
    CGFloat speed;
    CGFloat width;
    NSInteger pathwayNumber;
    CFTimeInterval startTime;
};
typedef struct QHDanmuCellParam QHDanmuCellParam;

struct QHDanmuViewDataSourceHas {
    NSUInteger playUseTimeOfPathwayCell;
};
typedef struct QHDanmuViewDataSourceHas QHDanmuViewDataSourceHas;

#define kQHDanmuPlayUseTime 6.0f
#define kQHDanmuPoolMaxCount 10

@interface QHDanmuView ()

// [Objective-C 内存管理——你需要知道的一切 - skyline75489 - SegmentFault 思否](https://segmentfault.com/a/1190000004943276)

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) NSMutableArray<NSDictionary *> *danmuDataList;
@property (nonatomic, strong) NSTimer *danmuTimer;
@property (nonatomic, readwrite) QHDanmuViewStyle style;

// [UITableviewCell复用机制 - 简书](https://www.jianshu.com/p/1046c741fce1)
@property (nonatomic, strong) NSMutableArray *reusableCells;
@property (nonatomic, strong) NSMutableDictionary *reusableCellsIdentifierDic;
@property (nonatomic, strong) NSMutableDictionary *cachedCellsParam;

@property (nonatomic) NSInteger pathwayCount;
@property (nonatomic) CGFloat pathwayHeight;
@property (nonatomic) QHDanmuViewDataSourceHas dataSourceHas;

@property (nonatomic) dispatch_queue_t danmuQueue;

@end

@implementation QHDanmuView

- (void)dealloc {
#if DEBUG
    NSLog(@"%s", __FUNCTION__);
#endif
    [self p_closeTimer];
    _danmuTimer = nil;
    
    _reusableCells = nil;
    _reusableCellsIdentifierDic = nil;
    _cachedCellsParam = nil;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _style = QHDanmuViewStyleCustom;
        [self p_setup];
    }
    return self;
}

// [iOS - layoutSubviews总结（作用及调用机制） - 简书](https://www.jianshu.com/p/a2acc4c7dc4b)
- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - Public

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame style:QHDanmuViewStyleCustom];
}

- (id)initWithFrame:(CGRect)frame style:(QHDanmuViewStyle)theStyle {
    self = [super initWithFrame:frame];
    if (self) {
        _style = theStyle;
        [self p_setup];
    }
    return self;
}

- (void)insertData:(NSArray<NSDictionary *> *)data {
    if (data == nil || data.count <= 0) {
        return;
    }
    if (_danmuDataList.count >= _danmuPoolMaxCount) {
        return;
    }
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:_cmd withObject:data waitUntilDone:NO];
        return;
    }
    NSArray *newData = data;
    if (data.count > 1) {
        NSUInteger s = self.danmuPoolMaxCount - self.danmuDataList.count;
        if (data.count > s) {
            newData = [data subarrayWithRange:NSMakeRange(0, s)];
        }
    }
    [self.danmuDataList addObjectsFromArray:newData];
    [self p_goDanmuTimer];
}

- (void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
    [_reusableCellsIdentifierDic setObject:cellClass forKey:identifier];
    QHDanmuViewCell *cell = [(QHDanmuViewCell *)[cellClass alloc] _qhDanmuInitWithReuseIdentifier:identifier];
    [_reusableCells addObject:cell];
    cell = nil;
}

- (nullable __kindof QHDanmuViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier {
    __block QHDanmuViewCell *cell = nil;
    Class class = [_reusableCellsIdentifierDic objectForKey:identifier];
    if (class != nil) {
        [_reusableCells enumerateObjectsUsingBlock:^(QHDanmuViewCell *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.reuseIdentifier == identifier) {
                cell = obj;
                *stop = NO;
            }
        }];
        if (cell != nil) {
            [_reusableCells removeObject:cell];
        }
        else {
            cell = [(QHDanmuViewCell *)[class alloc] _qhDanmuInitWithReuseIdentifier:identifier];
        }
    }
    return cell;
}

- (void)cleanData {
    [self p_closeTimer];
    /*
     1、使用 dispatch_barrier_async & dispatch_sync 解决数据竞争，对数组的删除导致崩溃
     [iOS-线程安全NSMutableArray - 简书](https://www.jianshu.com/p/0b5a97720ebe)
     2、Group 或者 dispatch_sync 会出现 EXC_BAD_INSTRUCTION 崩溃
     [ios - EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0) on dispatch_semaphore_dispose - Stack Overflow](https://stackoverflow.com/questions/24337791/exc-bad-instruction-code-exc-i386-invop-subcode-0x0-on-dispatch-semaphore-dis)
     3、NSLock 也会死锁
     [iOS 多线程基础 四、多线程安全——线程锁 - 简书](https://www.jianshu.com/p/27af7fae9947)
     4、使用 @synchronized 则依然会有数据竞争问题
     */
    dispatch_barrier_async(_danmuQueue, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        });
        [self.danmuDataList removeAllObjects];
        [self.reusableCells removeAllObjects];
        [self p_resetCachedCellsParam];
    });
}

#pragma mark - Private
         
- (void)p_setup {
    [self p_setupData];
    [self p_setupUI];
}

- (void)p_setupData {
    _danmuDataList = [NSMutableArray new];
    
    _reusableCells = [NSMutableArray new];
    _reusableCellsIdentifierDic = [NSMutableDictionary new];
    _cachedCellsParam = [NSMutableDictionary new];
    
    _pathwayCount = 0;
    _pathwayHeight = 0;
    _danmuPoolMaxCount = kQHDanmuPoolMaxCount;
    
    _dataSourceHas.playUseTimeOfPathwayCell = 0;
    
    _danmuQueue = dispatch_queue_create("com.danmu.queue", NULL);
}

- (void)p_setupUI {
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    _contentView.clipsToBounds = YES;
    [self addSubview:_contentView];
    [QHViewUtil fullScreen:_contentView];
}

- (void)p_closeTimer {
    [_danmuTimer invalidate];
    _danmuTimer = nil;
}

- (void)p_goDanmuTimer {
    if (_danmuTimer == nil) {
        __weak typeof(self) weakSelf = self;
        _danmuTimer = [NSTimer qheoc_scheduledTimerWithTimeInterval:0.2 block:^{
            dispatch_sync(weakSelf.danmuQueue, ^{
                for (int i = 0; i < weakSelf.pathwayCount; i++) {
                    BOOL bAction = [weakSelf p_danmuAction];
                    if (bAction == NO) {
                        break;
                    }
                }
            });
        } repeats:YES];
    }
}

- (BOOL)p_danmuAction {
    
    UIApplicationState state = [UIApplication sharedApplication].applicationState;
    if (state == UIApplicationStateBackground) {
        return NO;
    }
    
    if (_danmuDataList.count <= 0) {
        [self p_closeTimer];
        return NO;
    }
    
    NSDictionary *data = _danmuDataList.firstObject;
    if (data == nil) {
        return NO;
    }
    
    CGFloat playUseTime = kQHDanmuPlayUseTime;
    if (_dataSourceHas.playUseTimeOfPathwayCell == 1) {
        playUseTime = [_dataSource playUseTimeOfPathwayCellInDanmuView:self];
    }
    
    QHDanmuCellParam newParam = [self p_danmuParamWithPlayUseTime:playUseTime];
    
    if (newParam.pathwayNumber == -1) {
        return NO;
    }
    
    QHDanmuViewCell *cell = [_dataSource danmuView:self cellForPathwayWithData:data];
    if (cell == nil) {
        [_danmuDataList removeObjectAtIndex:0];
        return NO;
    }
    [self p_danmuAnimationOfFlyWithCell:cell param:newParam playUseTime:playUseTime];
    
    // 使用完清除弹幕池数据
    [_danmuDataList removeObjectAtIndex:0];
    return YES;
}

// 如果是深度优先， 这里的 _inCount 应该计算是否碰撞，而如果是广度优先，则先递增航道，重新回到最开始的航道，再计算碰撞。如果航道没有任何弹幕，则无需判断
- (QHDanmuCellParam)p_danmuParamWithPlayUseTime:(CGFloat)playUseTime {
    NSDictionary *data = _danmuDataList.firstObject;
    QHDanmuCellParam newParam;
    newParam.pathwayNumber = -1;
    
    for (int i = 0; i < _pathwayCount; i++) {
        // 记录时间
        newParam.startTime = CFAbsoluteTimeGetCurrent();
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        id obj = [_cachedCellsParam objectForKey:indexPath];
        if ([obj isKindOfClass:[NSNull class]] == YES) {
            // 记录宽度 & 计算速度
            newParam.width = [_delegate danmuView:self widthForPathwayWithData:data];
            newParam.speed = (newParam.width + self.frame.size.width) / playUseTime;
            newParam.pathwayNumber = i;
        }
        else if ([obj isKindOfClass:[NSValue class]] == YES) {
            QHDanmuCellParam lastParam;
            [(NSValue *)obj getValue:&lastParam];
            
            CFTimeInterval spaceTime = newParam.startTime - lastParam.startTime;
            if (spaceTime * lastParam.speed >= lastParam.width) {
                
                // 记录宽度 & 计算速度
                newParam.width = [_delegate danmuView:self widthForPathwayWithData:data];
                newParam.speed = (newParam.width + self.frame.size.width) / playUseTime;
                
                // 最后一个弹幕已完全显示在轨道
                // 如果最后弹幕的速度大于新的弹幕速度，则该轨道可与使用
                if (lastParam.speed >= newParam.speed) {
                    newParam.pathwayNumber = lastParam.pathwayNumber;
                }
                else {
                    // 最后一个弹幕剩余的滑动时间，新弹幕是否能在显示区域追上，判断新弹幕需要的时间与之比较。小于等于，则追不上，该轨道可使用；反之不可使用。
                    CGFloat useTimeInScreen = self.frame.size.width / newParam.speed;
                    if (useTimeInScreen >= (playUseTime - spaceTime)) {
                        newParam.pathwayNumber = lastParam.pathwayNumber;
                    }
                }
            }
            else {
                // 最后一个弹幕还没有完全显示在轨道（即尾部还未显示），则该轨道不可使用
            }
        }
        
        if (newParam.pathwayNumber >= 0) {
            break;
        }
    }
    
    // [CGGeometry - NSHipster](https://nshipster.cn/cggeometry/#%E5%B8%B8%E9%87%8F)
    if (newParam.pathwayNumber == -1) {
        // 有弹幕池，不符合的进入等待，不删除
        // [_danmuDataList removeObjectAtIndex:0];
        return newParam;
    }
    
    NSValue *newParamValue = [NSValue valueWithBytes:&newParam objCType:@encode(QHDanmuCellParam)];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:newParam.pathwayNumber inSection:0];
    [_cachedCellsParam setObject:newParamValue forKey:indexPath];
    
    return newParam;
}

- (void)p_danmuAnimationOfFlyWithCell:(QHDanmuViewCell *)cell param:(QHDanmuCellParam)param playUseTime:(CGFloat)playUseTime {
    
    cell.frame = CGRectMake(self.frame.size.width, (_pathwayHeight * param.pathwayNumber), param.width, _pathwayHeight);
    [_contentView addSubview:cell];
    
    CGRect goFrame = cell.frame;
    goFrame.origin.x = -cell.frame.size.width;
    [UIView animateWithDuration:playUseTime delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        cell.frame = goFrame;
    } completion:^(BOOL finished) {
        [self.reusableCells addObject:cell];
        [cell removeFromSuperview];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:param.pathwayNumber inSection:0];
        id obj = [self.cachedCellsParam objectForKey:indexPath];
        if ([obj isKindOfClass:[NSValue class]] == YES) {
            QHDanmuCellParam deleteParam;
            [(NSValue *)obj getValue:&deleteParam];
            if (deleteParam.startTime == param.startTime && deleteParam.pathwayNumber == param.pathwayNumber) {
                [self.cachedCellsParam setObject:[NSNull null] forKey:indexPath];
            }
        }
    }];
}

- (void)p_resetCachedCellsParam {
    [_cachedCellsParam removeAllObjects];
    for (int i = 0; i < _pathwayCount; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
        [_cachedCellsParam setObject:[NSNull null] forKey:indexPath];
    }
}

#pragma mark - Set

- (void)setDataSource:(id<QHDanmuViewDataSource>)dataSource {
    _dataSource = dataSource;
    
    _pathwayCount = [_dataSource numberOfPathwaysInDanmuView:self];
    _pathwayHeight = [_dataSource heightOfPathwayCellInDanmuView:self];
    
    _dataSourceHas.playUseTimeOfPathwayCell = [_dataSource respondsToSelector:@selector(playUseTimeOfPathwayCellInDanmuView:)];
    
    [self p_resetCachedCellsParam];
}

@end
