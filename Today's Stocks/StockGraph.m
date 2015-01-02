//
//  StockGraph.m
//  Stocks+
//
//  Created by Noah Martin on 8/17/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "StockGraph.h"

@interface StockGraph()

@end

@implementation StockGraph

-(instancetype)initWithSymbol:(NSString *)symbol {
    if(self = [super init]) {
        self.symbol = symbol;
        self.points = [[NSMutableArray alloc] init];
        return self;
    }
    return nil;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    if(self = [super init]) {
        self.symbol = [aDecoder decodeObjectForKey:@"symbol"];
        self.change = [aDecoder decodeObjectForKey:@"change"];
        self.changepercent = [aDecoder decodeDoubleForKey:@"changepercent"];
        self.open = [aDecoder decodeDoubleForKey:@"open"];
        self.realTimePrice = [aDecoder decodeDoubleForKey:@"realTimePrice"];
        self.marketClose = [aDecoder decodeDoubleForKey:@"marketClose"];
        self.marketOpen = [aDecoder decodeDoubleForKey:@"marketOpen"];
        self.points = [aDecoder decodeObjectForKey:@"points"];
        self.articles = [aDecoder decodeObjectForKey:@"articles"];
        self.name = [aDecoder decodeObjectForKey:@"name"];
        return self;
    }
    return nil;
}

-(void)updateWithData:(StockGraph *)newData {
    self.change = newData.change;
    self.changepercent = newData.changepercent;
    self.open = newData.open;
    self.realTimePrice = newData.realTimePrice;
    if(self.marketOpen == newData.marketOpen) {
        DataPoint* lastPoint =  self.points.lastObject;
        for(DataPoint* point in newData.points) {
            if([point getTimestamp] > [lastPoint getTimestamp])
            [self.points addObject:point];
        }
    } else {
        self.points = newData.points;
    }
    self.marketClose = newData.marketClose;
    self.marketOpen = newData.marketOpen;
    if(newData.articles.count) {
        self.articles = newData.articles;
    }
}

-(BOOL)isEqual:(id)object {
    if([object isKindOfClass:[StockGraph class]]) {
        return [self.symbol isEqualToString:((StockGraph*) object).symbol];
    }
    return false;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.symbol forKey:@"symbol"];
    [aCoder encodeObject:self.change forKey:@"change"];
    [aCoder encodeDouble:self.changepercent forKey:@"changepercent"];
    [aCoder encodeDouble:self.open forKey:@"open"];
    [aCoder encodeDouble:self.marketClose forKey:@"marketClose"];
    [aCoder encodeDouble:self.marketOpen forKey:@"marketOpen"];
    [aCoder encodeDouble:self.realTimePrice forKey:@"realTimePrice"];
    [aCoder encodeObject:self.points forKey:@"points"];
    [aCoder encodeObject:self.articles forKey:@"articles"];
    [aCoder encodeObject:self.name forKey:@"name"];
}

-(double)prevClose {
    return self.realTimePrice - [self.change doubleValue];
}

-(void)addDataPoint:(DataPoint *)dataPoint {
    [self.points addObject:dataPoint];
}

-(NSUInteger)numberOfPoints {
    return self.points.count;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"symbol: %@", self.symbol];
}

-(double)getMaxValue {
    // TODO: make this O(1) by just updating this as the points are added
    double max = -1;
    for(DataPoint* point in self.points) {
        if(point.price > max) {
            max = point.price;
        }
    }
    return max;
}

-(double)getMinValue {
    // TODO: make this O(1) by just updating this as the points are added

    // TODO: unhack this...
    double min = 99999999;
    for(DataPoint* point in self.points) {
        if(point.price < min) {
            min = point.price;
        }
    }
    return min;
}

@end
