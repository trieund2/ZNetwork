//
//  ZAOperationCallback.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZAOperationCallback : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSURL *url;
@property (nonatomic, readonly) ZAOperationPriority priority;
@property (nonatomic, readonly) NSURLRequestCachePolicy requestPolicy;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithURL:(NSURL *)url;
- (instancetype)initWithURL:(NSURL *)url operationPriority:(ZAOperationPriority)priority;
- (instancetype)initWithURL:(NSURL *)url operationPriority:(ZAOperationPriority)priority requestPolicy:(NSURLRequestCachePolicy)requestPolicy;

@end

NS_ASSUME_NONNULL_END
