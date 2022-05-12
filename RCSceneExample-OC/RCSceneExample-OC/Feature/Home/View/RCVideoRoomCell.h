//
//  RCVideoRoomCell.h
//  RCSceneExample-OC
//
//  Created by shaoshuai on 2022/5/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class RoomModel;

@interface RCVideoRoomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;

- (instancetype)updateUI:(RoomModel *)model;

@end

NS_ASSUME_NONNULL_END
