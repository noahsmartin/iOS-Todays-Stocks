//
//  NewsRequest.m
//  Stocks+
//
//  Created by Noah Martin on 8/27/14.
//  Copyright (c) 2014 Noah Martin. All rights reserved.
//

#import "NewsRequest.h"
#import "NewsArticle.h"

@interface NewsRequest() <NSXMLParserDelegate>
@property NSMutableArray* articles;
@property NewsArticle* article;
@property (strong) void (^block)(NSArray*);

@property BOOL title;
@property BOOL link;

@end

@implementation NewsRequest

-(void)getNewsForSymbol:(NSString *)symbol withBlock:(void (^)(NSArray *))block {
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    NSString* urlString = [NSString stringWithFormat:@"http://feeds.finance.yahoo.com/rss/2.0/headline?s=%@&region=US&lang=en-US", symbol];
    [request setURL:[NSURL URLWithString:urlString]];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if(!connectionError) {
            self.block = block;
            NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
            [parser setDelegate:self];
            [parser parse];
        }
    }];
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if(self.link) {
        if(self.article.url) {
            NSString* string = [self.article.url absoluteString];
            string = [string stringByAppendingString:string];
            self.article.url = [NSURL URLWithString:string];
        } else {
            self.article.url = [NSURL URLWithString:string];
        }
    } else if(self.title) {
        if(self.article.title) {
            self.article.title = [self.article.title stringByAppendingString:string];
        } else {
            self.article.title = string;
        }
    }
}

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if([elementName isEqualToString:@"channel"]) {
        self.articles = [[NSMutableArray alloc] init];
    } else if([elementName isEqualToString:@"item"]) {
        self.article = [[NewsArticle alloc] init];
    } else if([elementName isEqualToString:@"title"]) {
        self.title = YES;
    } else if([elementName isEqualToString:@"link"]) {
        self.link = YES;
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if([elementName isEqualToString:@"channel"]) {
        self.block(self.articles);
    } else if([elementName isEqualToString:@"item"]) {
        [self.articles addObject:self.article];
    } else if([elementName isEqualToString:@"title"]) {
        self.title = NO;
    } else if([elementName isEqualToString:@"link"]) {
        self.link = NO;
    }
}

@end
