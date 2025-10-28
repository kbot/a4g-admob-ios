//
//  Ad4CustomEvent.m
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import "Ad4CustomEvent.h"
#import "Ad4CustomEventIntertitial.h"
#import "Ad4CustomEventBanner.h"
#import "Ad4CustomEventRewarded.h"
#import "Ad4CustomEventNative.h"

@implementation Ad4CustomEvent{
    Ad4CustomEventRewarded *ad4Rewarded;
    Ad4CustomEventIntertitial *ad4Intertitial;
    Ad4CustomEventBanner *ad4Banner;
}

+ (void)setUpWithConfiguration:(nonnull GADMediationServerConfiguration *)configuration
             completionHandler:(nonnull GADMediationAdapterSetUpCompletionBlock)completionHandler {
  // This is where you initialize the SDK that this custom event is built
  // for. Upon finishing the SDK initialization, call the completion handler
  // with success.
  completionHandler(nil);
}

#pragma mark GADMediationAdapter implementation

+ (GADVersionNumber)adSDKVersion {
  NSArray *versionComponents = [Ad4SDKVersion componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count >= 3) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion = [versionComponents[2] integerValue];
  }
  return version;
}

+ (GADVersionNumber)adapterVersion {
  NSArray *versionComponents = [Ad4CustomEventAdapterVersion componentsSeparatedByString:@"."];
  GADVersionNumber version = {0};
  if (versionComponents.count == 4) {
    version.majorVersion = [versionComponents[0] integerValue];
    version.minorVersion = [versionComponents[1] integerValue];
    version.patchVersion =
        [versionComponents[2] integerValue] * 100 + [versionComponents[3] integerValue];
  }
  return version;
}

- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)completionHandler {
    ad4Intertitial = [[Ad4CustomEventIntertitial alloc] init];
    [ad4Intertitial loadInterstitialForAdConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration
                   completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler {
    ad4Banner = [[Ad4CustomEventBanner alloc] init];
  [ad4Banner loadBannerForAdConfiguration:adConfiguration completionHandler:completionHandler];
}

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler {
    ad4Rewarded = [[Ad4CustomEventRewarded alloc] init];
  [ad4Rewarded loadRewardedAdForAdConfiguration:adConfiguration
                                 completionHandler:completionHandler];
}

- (void)loadNativeAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(GADMediationNativeLoadCompletionHandler)completionHandler {
    Ad4CustomEventNative *ad4Native = [[Ad4CustomEventNative alloc] init];
    [ad4Native loadNativeAdForAdConfiguration:adConfiguration completionHandler:completionHandler];
}

@end
