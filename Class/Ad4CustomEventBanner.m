//
//  Ad4CustomEventBanner.m
//  AdmobMediation
//
//  Created by Ad4Game Team on 2023/4/7.
//

#import "Ad4CustomEventBanner.h"
#include <stdatomic.h>
#import <Foundation/Foundation.h>

@interface Ad4CustomEventBanner()<GADMediationBannerAd,GADBannerViewDelegate>{
    /// The sample banner ad.
    GADBannerView *_bannerAd;

    /// The completion handler to call when the ad loading succeeds or fails.
    GADMediationBannerLoadCompletionHandler _loadCompletionHandler;

    /// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
    id<GADMediationBannerAdEventDelegate> _adEventDelegate;
}

@end

@implementation Ad4CustomEventBanner

- (void)loadBannerForAdConfiguration:(GADMediationBannerAdConfiguration *)adConfiguration completionHandler:(GADMediationBannerLoadCompletionHandler)completionHandler{
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationBannerLoadCompletionHandler originalCompletionHandler =
        [completionHandler copy];

    _loadCompletionHandler = ^id<GADMediationBannerAdEventDelegate>(
        _Nullable id<GADMediationBannerAd> ad, NSError *_Nullable error) {
      // Only allow completion handler to be called once.
      if (atomic_flag_test_and_set(&completionHandlerCalled)) {
        return nil;
      }

      id<GADMediationBannerAdEventDelegate> delegate = nil;
      if (originalCompletionHandler) {
        // Call original handler and hold on to its return value.
        delegate = originalCompletionHandler(ad, error);
      }

      // Release reference to handler. Objects retained by the handler will also be released.
      originalCompletionHandler = nil;

      return delegate;
    };
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    _bannerAd = [[GADBannerView alloc]
          initWithAdSize: GADAdSizeBanner];
    _bannerAd.adUnitID = adUnit;
    _bannerAd.delegate = self;
    [_bannerAd loadRequest:[GADRequest request]];
    
}

- (void)bannerViewDidReceiveAd:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidReceiveAd");
    _adEventDelegate = _loadCompletionHandler(self, nil);
}

- (void)bannerView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(NSError *)error {
  NSLog(@"bannerView:didFailToReceiveAdWithError: %@", [error localizedDescription]);
    _adEventDelegate = _loadCompletionHandler(nil, error);
}

- (void)bannerViewDidRecordImpression:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidRecordImpression");
    [_adEventDelegate reportImpression];
    
}

- (void)bannerViewWillPresentScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillPresentScreen");
    [_adEventDelegate willPresentFullScreenView];
}

- (void)bannerViewWillDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewWillDismissScreen");
    [_adEventDelegate willDismissFullScreenView];
}

- (void)bannerViewDidDismissScreen:(GADBannerView *)bannerView {
  NSLog(@"bannerViewDidDismissScreen");
    [_adEventDelegate didDismissFullScreenView];
}

- (void)bannerViewDidRecordClick:(GADBannerView *)bannerView{
    [_adEventDelegate reportClick];
}

- (nonnull UIView *)view {
  return _bannerAd;
}

@end
