//
//  UIVew+MKAnnotationView.m
//  HomeWork37-38 MapKit
//
//  Created by Oleh Veheria on 6/16/16.
//  Copyright © 2016 Selfie. All rights reserved.
//

#import "UIView+MKAnnotationView.h"
#import <MapKit/MKAnnotationView.h>

@implementation UIView (MKAnnotationView)

- (MKAnnotationView *)superAnnotationView {
    if ([self isKindOfClass:[MKAnnotationView class]]) {
        return (MKAnnotationView *)self;
    }
    
    if (!self.superview) {
        return nil;
    }
    
    return [self.superview superAnnotationView];
}

@end
