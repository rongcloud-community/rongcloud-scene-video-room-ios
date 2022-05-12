//
//  RCVideoRoomCell.m
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import "RCVideoRoomCell.h"

#import "RoomModel.h"
#import <SDWebImage/SDWebImage.h>

@implementation RCVideoRoomCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (instancetype)updateUI:(RoomModel *)model {
    self.titleLabel.text = model.roomName;
    NSURL *imageURL = [NSURL URLWithString:model.themePictureUrl];
    if (imageURL) [self.avatarView sd_setImageWithURL:imageURL];
    return self;
}

@end
