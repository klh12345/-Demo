//
//  ConnectCell.h
//  ConnectDemo
//
//  Created by 中国孔 on 2019/2/22.
//  Copyright © 2019 孔令辉. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ConnectCell;
@class ConnectModel;
@protocol ConnectSelectActionDelegate <NSObject>

- (void)selectBtnActionWithCell:(ConnectCell *)cell;

@end

@interface ConnectCell : UITableViewCell

@property (strong , nonatomic) UIButton *selectbtn;
@property (strong , nonatomic) UILabel *connect;
@property (strong , nonatomic) UILabel *numbers;


@property (strong , nonatomic)id<ConnectSelectActionDelegate>delegate;

- (void)bindDataSource:(ConnectModel *)model;

@end

NS_ASSUME_NONNULL_END
