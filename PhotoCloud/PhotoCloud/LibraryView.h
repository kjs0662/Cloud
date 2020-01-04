//
//  LibraryView.h
//  PhotoCloud
//
//  Created by Jinseon Kim on 2019/12/31.
//  Copyright © 2019 Jinseon Kim. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LibraryViewDelegate;

@interface LibraryView : UIViewController

@property (nonatomic, weak)id<LibraryViewDelegate> delegate;

@end

@protocol LibraryViewDelegate <NSObject>

- (void)libraryViewDelegateDidUploadPhoto:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
