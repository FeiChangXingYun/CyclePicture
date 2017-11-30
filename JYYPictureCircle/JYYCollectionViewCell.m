//
//  JYYCollectionViewCell.m
//  JYYPictureCircle
//
//  Created by Yanyan Jiang on 2017/11/29.
//  Copyright © 2017年 Yanyan Jiang. All rights reserved.
//

#import "JYYCollectionViewCell.h"

@interface JYYCollectionViewCell()

@property (strong, nonatomic) UIImageView *iconImage;

@end


@implementation JYYCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.iconImage];
    }
    return self;
}



#pragma mark -setter & getter
-(UIImageView *)iconImage{
    if(!_iconImage){
        _iconImage = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _iconImage;
}

-(void)setImageUrl:(NSURL *)imageUrl{
    _imageUrl = imageUrl;
    NSData *data = [NSData dataWithContentsOfURL:imageUrl];
    UIImage *image = [UIImage imageWithData:data];
    self.iconImage.image = image;
}

@end
