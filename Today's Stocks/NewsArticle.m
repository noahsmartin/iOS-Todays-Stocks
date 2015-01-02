//
//  NewsArticle.m
//  Stocks+
//
//  Created by Noah Martin on 8/27/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "NewsArticle.h"

@implementation NewsArticle

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        return self;
    }
    return nil;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.title forKey:@"title"];
    [aCoder encodeObject:self.url forKey:@"url"];
}

-(NSString*)description {
    return self.title;
}

@end
