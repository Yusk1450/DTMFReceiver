//
//  FFT.h
//  DTMFReceiver
//
//  Created by 石郷 祐介 on 2014/06/28.
//  Copyright (c) 2014年 Yusk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFT : NSObject

@property (nonatomic) NSUInteger capacity;

- (id)initWithCapacity:(NSUInteger)capacity;
- (void)process:(float *)input;
- (float)spectrum:(NSUInteger)index;

@end
