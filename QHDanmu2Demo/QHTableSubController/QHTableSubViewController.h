//
//  QHTableSubViewController.h
//  QHTableViewDemo
//
//  Created by chen on 17/3/21.
//  Copyright © 2017年 chen. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "QHDanmuView.h"

#define kSLCDanmuViewCellContentIdentifier @"danmuViewCellContentIdentifier"

@interface QHTableSubViewController : UIViewController <QHDanmuViewDataSource, QHDanmuViewDelegate>

@property (weak, nonatomic) IBOutlet UIView *playView;
@property (weak, nonatomic) IBOutlet UISwitch *danmuSwitch;

@property (nonatomic, strong) QHDanmuView *danmuView;

@end
