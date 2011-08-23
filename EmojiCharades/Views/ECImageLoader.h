//
//  ECImageLoader.h
//  EmojiCharades
//
//  Created by Gabriel Handford on 8/22/11.
//  Copyright 2011. All rights reserved.
//

@class ECImageLoader;

@protocol ECImageLoaderDelegate <NSObject>
- (void)imageLoader:(ECImageLoader *)loader didLoadImage:(UIImage *)image;
- (void)imageLoader:(ECImageLoader *)loader didError:(NSError *)error;
@end


@interface ECImageLoader : NSObject {  
	NSURLConnection *_connection;  
	NSMutableData *_data;  
	UIImage *_image;  
	id<ECImageLoaderDelegate> delegate;
}

@property (nonatomic, assign) id<ECImageLoaderDelegate> delegate; 

- (void)loadWithURL:(NSURL *)URL;

- (void)cancel;

@end

