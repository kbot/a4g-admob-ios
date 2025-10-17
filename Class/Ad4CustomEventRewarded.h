//
//  Ad4CustomEventRewarded.h
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
NS_ASSUME_NONNULL_BEGIN

@interface Ad4CustomEventRewarded : NSObject
- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration
                       completionHandler:
                           (GADMediationRewardedLoadCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
