//
//  ConnectCell.m
//  ConnectDemo
//
//  Created by 中国孔 on 2019/2/22.
//  Copyright © 2019 孔令辉. All rights reserved.
//

#import "ConnectCell.h"
#import "Masonry/Masonry.h"
#import "ConnectModel.h"
@implementation ConnectCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self layoutUI];
    }
    
    return self;
}

- (void)layoutUI{
    
    self.selectbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.selectbtn setImage:[UIImage imageNamed:@"ZXKF_nav_weixuanzhong"] forState:UIControlStateNormal];
    [self.selectbtn setImage:[UIImage imageNamed:@"ZXKF_nav_xuanzhong"] forState:UIControlStateSelected];
    [self.selectbtn addTarget:self action:@selector(senderAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.selectbtn];
    
    self.connect = [[UILabel alloc] init];
    self.connect.font = [UIFont systemFontOfSize:13.0f];
    self.connect.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    [self.contentView addSubview:self.connect];
    
    
    self.numbers = [[UILabel alloc] init];
    self.numbers.font = [UIFont systemFontOfSize:13.0f];
    self.numbers.textColor = [UIColor colorWithRed:51.0f/255.0f green:51.0f/255.0f blue:51.0f/255.0f alpha:1.0f];
    
    [self.contentView addSubview:self.numbers];
    
    [self.selectbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(8);
        make.size.mas_equalTo(CGSizeMake(35, 35));
    }];
    
    [self.connect mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.selectbtn.mas_right).offset(15);
    }];
    
    [self.numbers mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.connect.mas_right).offset(15);
    }];
    
    
}

- (void)senderAction:(UIButton *)sender{
    
    sender.selected = !sender.selected;
    
    if ([self.delegate respondsToSelector:@selector(selectBtnActionWithCell:)]) {
        [self.delegate selectBtnActionWithCell:self];
    }
    
}


- (void)bindDataSource:(ConnectModel *)model{
    
    self.connect.text = model.name;
    self.numbers.text = model.phone;
    
    
    self.selectbtn.selected = model.isSelected;
   
    
}

@end
