//
//  DataPoint.h
//  Stocks+
//
//  Created by Noah Martin on 8/16/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataPoint : NSObject <NSCoding>
-(instancetype)initWithDictionary:(NSDictionary*)dictionary;
@property double price;
-(long long)getTimestamp;


@end
