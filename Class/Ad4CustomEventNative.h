//
//  Ad4CustomEventNative.h
//  AdmobMediation
//
//  Created by Ad4Game Team on 2025/10/17.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

NS_ASSUME_NONNULL_BEGIN

@interface Ad4CustomEventNative : NSObject

/// Loads a native ad for the given ad configuration and calls the completion handler.
/// @param adConfiguration The native ad configuration.
/// @param completionHandler The completion handler to call after the ad loading process.
- (void)loadNativeAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(GADMediationNativeLoadCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END