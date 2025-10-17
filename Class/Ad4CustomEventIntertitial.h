//
//  Ad4CustomEventIntertitial.h
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import <Foundation/Foundation.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
NS_ASSUME_NONNULL_BEGIN

@interface Ad4CustomEventIntertitial : NSObject
- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
                             (GADMediationInterstitialLoadCompletionHandler)completionHandler;
@end

NS_ASSUME_NONNULL_END
