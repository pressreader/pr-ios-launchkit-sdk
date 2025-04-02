//
//  PRAppLaunchKit.h
//  PRAppLaunchKit
//
//  Created by Vitali Bounine on 2015-03-10.
//  Copyright (c) 2015 NewspaperDirect. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for PRAppLaunchKit.
FOUNDATION_EXPORT double PRAppLaunchKitVersionNumber;

//! Project version string for PRAppLaunchKit.
FOUNDATION_EXPORT const unsigned char PRAppLaunchKitVersionString[];

NS_ASSUME_NONNULL_BEGIN

@interface PRAppLaunchKit : NSObject

@property (nonatomic, copy) NSString * subscriptionKey; // key used to access https://developers.pressreader.com

@property (nonatomic, copy) NSString * scheme; // default 'PressReader'
@property (nonatomic, copy) NSString * hostName; // default 'PressDisplay.com'
@property (nonatomic, copy) NSString * appStoreID; // default '313904711'
@property (nonatomic, copy) NSString * baseApiURL; // default 'https://api.pressreader.com/v1/deviceactivation/' for beta services set to 'https://services.pressreader.com/test/dev/deviceactivation/registerparameters/'

+ (instancetype) defaultAppLaunch;

- (instancetype) initWithScheme:(NSString *)scheme hostName:(NSString *)hostName appStoreID:(NSString *)appStoreID;
- (instancetype) initWithScheme:(NSString *)scheme;

- (BOOL) isAppInstalled;
- (void) launchAppWithCommand:(nullable NSString *)command URLParameters:(nullable NSDictionary *)urlParameters;
- (void) launchAppWithCommand:(nullable NSString *)command URLParameters:(nullable NSDictionary *)urlParameters forceSendingToServer:(BOOL)forceSendingToServer;
- (void) launchAppWithURLParameters:(nullable NSDictionary *)urlParameters;
- (void) installApp;

NS_ASSUME_NONNULL_END

@end
