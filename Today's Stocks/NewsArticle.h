//
//  NewsArticle.h
//  Stocks+
//
//  Created by Noah Martin on 8/27/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsArticle : NSObject <NSCoding>

@property NSURL* url;
@property NSString* title;

@end
