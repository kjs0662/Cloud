//
//  PhotoCell.h
//  PhotoCloud
//
//  Created by Jinseon Kim on 2020/01/02.
//  Copyright © 2020 Jinseon Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *selectedView;

@end

NS_ASSUME_NONNULL_END
