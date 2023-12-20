//
//  UICollectionViewCell+SLExtension.m
//  SLDevKit
//
//  Created by 曾祥翔 on 2023/11/21.
//

#import "UICollectionViewCell+SLExtension.h"

@implementation UICollectionViewCell (SLExtension)

+ (void)sl_registerForCollectionView:(UICollectionView *)collectionView {
    Class cls = self;
    [collectionView registerClass:cls forCellWithReuseIdentifier:NSStringFromClass(cls)];
}

+ (UICollectionViewCell *)sl_dequeueReusableCellInCollectionView:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(self) forIndexPath:indexPath];
    return cell;
}

@end
