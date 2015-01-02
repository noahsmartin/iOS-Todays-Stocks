//
//  StockGraph.h
//  Stocks+
//
//  Created by Noah Martin on 8/17/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataPoint.h"

@interface StockGraph : NSObject <NSCoding>

@property NSString* symbol;
@property NSString* name;
@property (strong) NSMutableArray* points;
@property (strong) NSString* change;
@property double changepercent;
@property double open;
@property long long marketClose;
@property long long marketOpen;
@property double realTimePrice;
@property (readonly) double prevClose;
@property NSArray* articles;

-(instancetype)initWithSymbol:(NSString*)symbol;

-(void)addDataPoint:(DataPoint*)dataPoint;
-(NSUInteger)numberOfPoints;

-(double)getMinValue;
-(double)getMaxValue;
-(void)updateWithData:(StockGraph*)newData;

@end
