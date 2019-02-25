//
//  BottomeView.m
//  ConnectDemo
//
//  Created by 中国孔 on 2019/2/25.
//  Copyright © 2019 孔令辉. All rights reserved.
//

#import "BottomeView.h"

@implementation BottomeView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self layoutSubView];
    }
    return self;
}

- (void)layoutSubView{
    
    self.backgroundColor = [UIColor colorWithRed:100.0f/255.0f green:100.0f/255.0f blue:100.0f/255.0f alpha:1.0f];
    
    self.selectStatus = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 100, 30)];
    self.selectStatus.textColor = [UIColor whiteColor];
    self.selectStatus.font = [UIFont systemFontOfSize:14.0f];
    [self addSubview:self.selectStatus];
    
}



@end
