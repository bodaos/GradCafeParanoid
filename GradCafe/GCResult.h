//
//  GCResult.h
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GCResult : NSObject
@property (nonatomic, copy) NSString *university;
@property (nonatomic, copy) NSString *decision;
@property (nonatomic, copy) NSString *field;
@property (nonatomic, copy) NSString *interaction;

-(id) initWithUniversity: (NSString*) university andDecision: (NSString*) decision;
@end
