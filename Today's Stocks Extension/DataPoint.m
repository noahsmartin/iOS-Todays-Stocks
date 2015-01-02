//
//  DataPoint.m
//  Stocks+
//
//  Created by Noah Martin on 8/16/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "DataPoint.h"

@interface DataPoint()
@property long long timestamp;
@end

@implementation DataPoint

-(instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if(self = [super init]) {        
        self.timestamp = [[dictionary valueForKey:@"timestamp"] longLongValue];
        self.price = [[dictionary objectForKey:@"open"] doubleValue];
        return self;
    }
    return nil;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.timestamp = [[aDecoder decodeObjectForKey:@"timestamp"] longLongValue];
        self.price = [aDecoder decodeDoubleForKey:@"price"];
        return self;
    }
    return nil;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSString stringWithFormat:@"%lld", self.timestamp] forKey:@"timestamp"];
    [aCoder encodeDouble:self.price forKey:@"price"];
}

-(double)getPrice {
    return _price;
}

-(long long)getTimestamp {
    return _timestamp;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"%f", self.price];
}

@end
