//
//  PhotoModel.h
//  PhotoCloud
//
//  Created by Jinseon Kim on 2020/01/06.
//  Copyright © 2020 Jinseon Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PhotoModel : NSObject

@property (nonatomic, strong, nonnull) NSString *identifier;
@property (nonatomic, strong, nullable) NSString *thumbnailImage;
@property (nonatomic, strong, nonnull) NSString *image;
@property (nonatomic, strong, nonnull) NSString *createdData;

@end

NS_ASSUME_NONNULL_END
