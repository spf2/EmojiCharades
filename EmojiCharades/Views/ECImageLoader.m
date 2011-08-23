//
//  ECImageLoader.m
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011. All rights reserved.
//

#import "ECImageLoader.h"

@implementation ECImageLoader

@synthesize delegate=_delegate;

- (void)dealloc {
	[_connection release];
	[_data release];
  [super dealloc];
}

- (void)loadWithURL:(NSURL *)URL { 
	NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:URL] autorelease];
  [_connection cancel];
  [_connection release];
	_connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  [_data release];
	_data = [[NSMutableData alloc] init];
}

- (void)cancel {
  [_connection cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
  [delegate imageLoader:self didError:error];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[_connection release];
  _connection = nil;
	UIImage *image = [[UIImage alloc] initWithData:_data];
  [_delegate imageLoader:self didLoadImage:image];
  [image release];
  [_data release];
  _data = nil;
}

@end