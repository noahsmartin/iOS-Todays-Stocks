//
//  NewsRequest.h
//  Stocks+
//
//  Created by Noah Martin on 8/27/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NewsRequest : NSObject

-(void)getNewsForSymbol:(NSString*)symbol withBlock:(void (^)(NSArray *))block;

@end
