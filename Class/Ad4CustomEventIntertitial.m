//
//  Ad4CustomEventIntertitial.m
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import "Ad4CustomEventIntertitial.h"
#include <stdatomic.h>
#import <Foundation/Foundation.h>
@interface Ad4CustomEventIntertitial ()<GADFullScreenContentDelegate,GADMediationInterstitialAd>{
    /// The sample interstitial ad.
    GADInterstitialAd *_interstitialAd;
    
    /// The completion handler to call when the ad loading succeeds or fails.
    GADMediationInterstitialLoadCompletionHandler _loadCompletionHandler;

    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    id<GADMediationInterstitialAdEventDelegate> _adEventDelegate;
}

@end

@implementation Ad4CustomEventIntertitial

- (void)loadInterstitialForAdConfiguration:
            (GADMediationInterstitialAdConfiguration *)adConfiguration
                         completionHandler:
(GADMediationInterstitialLoadCompletionHandler)completionHandler{
    
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationInterstitialLoadCompletionHandler originalCompletionHandler =
        [completionHandler copy];
    
    _loadCompletionHandler = ^id<GADMediationInterstitialAdEventDelegate>(
        _Nullable id<GADMediationInterstitialAd> ad, NSError *_Nullable error) {
      // Only allow completion handler to be called once.
      if (atomic_flag_test_and_set(&completionHandlerCalled)) {
        return nil;
      }

      id<GADMediationInterstitialAdEventDelegate> delegate = nil;
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
      [GADInterstitialAd loadWithAdUnitID:adUnit
                                  request:request
                        completionHandler:^(GADInterstitialAd *ad, NSError *error) {
        if (error) {
          NSLog(@"Failed to load interstitial ad with error: %@", [error localizedDescription]);
            self->_adEventDelegate = self->_loadCompletionHandler(nil, error);
          return;
        }
          self->_adEventDelegate = self->_loadCompletionHandler(self, nil);
          self->_interstitialAd = ad;
          self->_interstitialAd.fullScreenContentDelegate = self;
      }];
}

/// Tells the delegate that the ad failed to present full screen content.
- (void)ad:(nonnull id<GADFullScreenPresentingAd>)ad
didFailToPresentFullScreenContentWithError:(nonnull NSError *)error {
    NSLog(@"Ad did fail to present full screen content.");
    _adEventDelegate = _loadCompletionHandler(self, error);
}

/// Tells the delegate that the ad will present full screen content.
- (void)adWillPresentFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
    NSLog(@"Ad will present full screen content.");
    [_adEventDelegate willPresentFullScreenView];
}

/// Tells the delegate that the ad dismissed full screen content.
- (void)adDidDismissFullScreenContent:(nonnull id<GADFullScreenPresentingAd>)ad {
   NSLog(@"Ad did dismiss full screen content.");
    [_adEventDelegate didDismissFullScreenView];
}

- (void)adDidRecordClick:(id<GADFullScreenPresentingAd>)ad{
    [_adEventDelegate reportClick];
}

- (void)adDidPresentFullScreenContent:(id<GADFullScreenPresentingAd>)ad{
      [_adEventDelegate reportImpression];
}

- (void)presentFromViewController:(UIViewController *)viewController {
    if (_interstitialAd) {
        [_interstitialAd presentFromRootViewController:viewController];
    }
}

@end
