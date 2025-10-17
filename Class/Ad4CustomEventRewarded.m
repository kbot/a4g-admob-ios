//
//  Ad4CustomEventRewarded.m
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import "Ad4CustomEventRewarded.h"
#include <stdatomic.h>
#import <Foundation/Foundation.h>

@interface Ad4CustomEventRewarded()<GADFullScreenContentDelegate,GADMediationRewardedAd>{
    GADRewardedAd *_rewardedAd;

    /// Completion handler to call when sample rewarded ad finishes loading.
    GADMediationRewardedLoadCompletionHandler _loadCompletionHandler;

    ///  Delegate for receiving rewarded ad notifications.
    id<GADMediationRewardedAdEventDelegate> _adEventDelegate;
}

@end

@implementation Ad4CustomEventRewarded

- (void)loadRewardedAdForAdConfiguration:(GADMediationRewardedAdConfiguration *)adConfiguration completionHandler:(GADMediationRewardedLoadCompletionHandler)completionHandler{
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationRewardedLoadCompletionHandler originalCompletionHandler =
        [completionHandler copy];

    _loadCompletionHandler = ^id<GADMediationRewardedAdEventDelegate>(
        _Nullable id<GADMediationRewardedAd> ad, NSError *_Nullable error) {
      // Only allow completion handler to be called once.
      if (atomic_flag_test_and_set(&completionHandlerCalled)) {
        return nil;
      }

      id<GADMediationRewardedAdEventDelegate> delegate = nil;
      if (originalCompletionHandler) {
        // Call original handler and hold on to its return value.
        delegate = originalCompletionHandler(ad, error);
      }

      // Release reference to handler. Objects retained by the handler will also be released.
      originalCompletionHandler = nil;

      return delegate;
    };
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    GADRequest *request = [GADRequest request];
      [GADRewardedAd
           loadWithAdUnitID:adUnit
                    request:request
          completionHandler:^(GADRewardedAd *ad, NSError *error) {
            if (error) {
              NSLog(@"Rewarded ad failed to load with error: %@", [error localizedDescription]);
                self->_adEventDelegate = self->_loadCompletionHandler(nil, error);
              return;
            }
          self->_rewardedAd = ad;
          self->_rewardedAd.fullScreenContentDelegate = self;
          self->_adEventDelegate = self->_loadCompletionHandler(self, nil);
            NSLog(@"Rewarded ad loaded.");
          }];
    
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
    didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad{
    [_adEventDelegate reportClick];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad did dismiss full screen content.");
    [_adEventDelegate willDismissFullScreenView];
    [_adEventDelegate didEndVideo];
    [_adEventDelegate didDismissFullScreenView];
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad{
    [_adEventDelegate willPresentFullScreenView];
    [_adEventDelegate didStartVideo];
    [_adEventDelegate reportImpression];
}

- (void)presentFromViewController:(UIViewController *)viewController{
    if (_rewardedAd) {
        [_rewardedAd presentFromRootViewController:viewController
                                      userDidEarnRewardHandler:^{
            [self->_adEventDelegate didRewardUser];
                                    }];
      }
}

@end
