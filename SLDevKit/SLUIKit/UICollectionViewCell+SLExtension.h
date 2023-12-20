//
//  UICollectionViewCell+SLExtension.h
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/11/21.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionViewCell (SLExtension)

+ (void)sl_registerForCollectionView:(UICollectionView *)collectionView;

+ (UICollectionViewCell *)sl_dequeueReusableCellInCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
