//
//  ZAOperationCallback.h
//  ZNetwork
//
//  Created by CPU12202 on 5/29/19.
//  Copyright © 2019 com.trieund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZADefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZAOperationCallback : NSObject

@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) ZAOperationPriority priority;

- (instancetype)init;
- (instancetype)initWithOperationPriority:(ZAOperationPriority)priority;

@end

NS_ASSUME_NONNULL_END
