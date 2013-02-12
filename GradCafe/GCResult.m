//
//  GCResult.m
//  GradCafe
//
//  Created by Shunji Li on 13-2-11.
//  Copyright (c) 2013年 Shunji Li. All rights reserved.
//

#import "GCResult.h"

@implementation GCResult
@synthesize university= _university, decision = _decision, field = _field, interaction = _interaction;


-(id) initWithUniversity: (NSString*) university andDecision: (NSString*) decision;{
    self = [super init];
    _university = university;
    _decision = decision;
    return self;
}
@end
