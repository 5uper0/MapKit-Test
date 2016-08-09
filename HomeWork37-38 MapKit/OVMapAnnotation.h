//
//  OVMapAnnotation.h
//  HomeWork 37-38 MKMap
//
//  Created by Oleh Veheria on 6/15/16.
//  Copyright © 2016 Selfie. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MKAnnotation.h>
#import "OVStudent.h"

@interface OVMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

@property (strong, nonatomic) OVStudent *student;
@property (assign, nonatomic) CLLocationDistance distance;

@end
