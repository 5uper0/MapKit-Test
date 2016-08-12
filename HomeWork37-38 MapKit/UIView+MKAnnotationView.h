//
//  UIVew+MKAnnotationView.h
//  HomeWork37-38 MapKit
//
//  Created by Oleh Veheria on 6/16/16.
//  Copyright © 2016 Selfie. All rights reserved.
//
#import <UIKit/UIKit.h>

@class MKAnnotationView;

@interface UIView (MKAnnotationView)

// use this method to find UIView's object superView of MKAnnotationView subclass
- (MKAnnotationView *)superAnnotationView;

@end
