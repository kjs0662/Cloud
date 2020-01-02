//
//  PhotoCell.m
//  PhotoCloud
//
//  Created by Jinseon Kim on 2020/01/02.
//  Copyright © 2020 Jinseon Kim. All rights reserved.
//

#import "PhotoCell.h"

@interface PhotoCell()

@end

@implementation PhotoCell

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (selected) {
        [self.selectedView setHidden:NO];
    } else {
        [self.selectedView setHidden:YES];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self.selectedView setHidden:YES];
}

@end
