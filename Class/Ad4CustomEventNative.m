//
//  Ad4CustomEventNative.m
//  AdmobMediation
//
//  Created by Ad4Game Team on 2025/10/17.
//

#import "Ad4CustomEventNative.h"
#include <stdatomic.h>
#import <Foundation/Foundation.h>

@interface Ad4CustomEventNative() <GADMediationNativeAd, GADNativeAdLoaderDelegate, GADNativeAdDelegate>

/// The completion handler to call when the ad loading succeeds or fails.
@property(nonatomic, copy) GADMediationNativeLoadCompletionHandler loadCompletionHandler;

/// The ad event delegate to forward ad rendering events to the Google Mobile Ads SDK.
@property(nonatomic, weak) id<GADMediationNativeAdEventDelegate> adEventDelegate;

/// The native ad configuration.
@property(nonatomic, strong) GADMediationNativeAdConfiguration *adConfiguration;

/// The Ad4Game native ad (using GADNativeAd as the underlying implementation).
@property(nonatomic, strong) GADNativeAd *nativeAd;

/// The GADAdLoader for loading native ads.
@property(nonatomic, strong) GADAdLoader *adLoader;

/// Images for the native ad.
@property(nonatomic, strong) NSArray<GADNativeAdImage *> *images;

/// Icon for the native ad.
@property(nonatomic, strong) GADNativeAdImage *icon;

@end

@implementation Ad4CustomEventNative

- (void)loadNativeAdForAdConfiguration:(GADMediationNativeAdConfiguration *)adConfiguration
                     completionHandler:(GADMediationNativeLoadCompletionHandler)completionHandler {
    
    __block atomic_flag completionHandlerCalled = ATOMIC_FLAG_INIT;
    __block GADMediationNativeLoadCompletionHandler originalCompletionHandler = [completionHandler copy];
    
    self.loadCompletionHandler = ^id<GADMediationNativeAdEventDelegate>(
        _Nullable id<GADMediationNativeAd> ad, NSError *_Nullable error) {
        // Only allow completion handler to be called once.
        if (atomic_flag_test_and_set(&completionHandlerCalled)) {
            return nil;
        }
        
        id<GADMediationNativeAdEventDelegate> delegate = nil;
        if (originalCompletionHandler) {
            // Call original handler and hold on to its return value.
            delegate = originalCompletionHandler(ad, error);
        }
        
        // Release reference to handler. Objects retained by the handler will also be released.
        originalCompletionHandler = nil;
        
        return delegate;
    };
    
    self.adConfiguration = adConfiguration;
    
    // Get the ad unit ID from the mediation configuration
    NSString *adUnit = adConfiguration.credentials.settings[@"parameter"];
    
    if (!adUnit || adUnit.length == 0) {
        NSError *error = [NSError errorWithDomain:@"Ad4CustomEventNative"
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey: @"Ad unit ID is missing"}];
        self.adEventDelegate = self.loadCompletionHandler(nil, error);
        return;
    }
    
    // Create GADAdLoader for native ads
    self.adLoader = [[GADAdLoader alloc] initWithAdUnitID:adUnit
                                       rootViewController:adConfiguration.topViewController
                                                  adTypes:@[GADAdLoaderAdTypeNative]
                                                  options:nil];
    self.adLoader.delegate = self;
    
    // Load the ad
    [self.adLoader loadRequest:[GADRequest request]];
}

#pragma mark - GADAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didFailToReceiveAdWithError:(NSError *)error {
    NSLog(@"Native ad failed to load with error: %@", [error localizedDescription]);
    self.adEventDelegate = self.loadCompletionHandler(nil, error);
}

#pragma mark - GADNativeAdLoaderDelegate

- (void)adLoader:(GADAdLoader *)adLoader didReceiveNativeAd:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad loaded successfully");
    
    self.nativeAd = nativeAd;
    self.nativeAd.delegate = self;
    
    // Process ad assets for mediation
    [self processNativeAdAssets];
    
    // Call completion handler with success
    self.adEventDelegate = self.loadCompletionHandler(self, nil);
}

#pragma mark - GADMediationNativeAd Protocol

- (NSString *)headline {
    return self.nativeAd.headline;
}

- (NSString *)body {
    return self.nativeAd.body;
}

- (NSArray<GADNativeAdImage *> *)images {
    return self.images;
}

- (GADNativeAdImage *)icon {
    return self.icon;
}

- (NSString *)callToAction {
    return self.nativeAd.callToAction;
}

- (NSDecimalNumber *)starRating {
    return self.nativeAd.starRating;
}

- (NSString *)store {
    return self.nativeAd.store;
}

- (NSString *)price {
    return self.nativeAd.price;
}

- (NSString *)advertiser {
    return self.nativeAd.advertiser;
}

- (NSDictionary *)extraAssets {
    return @{};
}

- (UIView *)adChoicesView {
    return nil; // AdChoices will be handled automatically by the SDK
}

- (UIView *)mediaView {
    return nil; // Return nil to use default media handling
}

- (BOOL)hasVideoContent {
    return self.nativeAd.mediaContent.hasVideoContent;
}

- (BOOL)handlesUserClicks {
    return YES;
}

- (BOOL)handlesUserImpressions {
    return YES;
}

#pragma mark - GADMediatedUnifiedNativeAd Protocol

- (void)didRenderInView:(UIView *)view
       clickableAssetViews:(NSDictionary<GADNativeAssetIdentifier, UIView *> *)clickableAssetViews
    nonclickableAssetViews:(NSDictionary<GADNativeAssetIdentifier, UIView *> *)nonclickableAssetViews
            viewController:(UIViewController *)viewController {
    
    // This method is called when the native ad is rendered.
    // You can add any custom tracking or setup here.
    NSLog(@"Native ad rendered in view");
}

- (void)didUntrackView:(UIView *)view {
    // This method is called when the native ad is no longer rendered in the provided view.
    NSLog(@"Native ad untracked from view");
}

- (void)didRecordImpression {
    // This method is called to record an impression.
    NSLog(@"Native ad impression recorded");
    [self.adEventDelegate reportImpression];
}

- (void)didRecordClickOnAssetWithName:(GADNativeAssetIdentifier)assetName
                                 view:(UIView *)view
                       viewController:(UIViewController *)viewController {
    // This method is called when a click is recorded on the native ad.
    NSLog(@"Native ad click recorded on asset: %@", assetName);
    [self.adEventDelegate reportClick];
}

#pragma mark - GADNativeAdDelegate

- (void)nativeAdDidRecordClick:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad click recorded");
    [self.adEventDelegate reportClick];
}

- (void)nativeAdDidRecordImpression:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad impression recorded");
    [self.adEventDelegate reportImpression];
}

- (void)nativeAdWillPresentScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad will present screen");
    [self.adEventDelegate willPresentFullScreenView];
}

- (void)nativeAdWillDismissScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad will dismiss screen");
    [self.adEventDelegate willDismissFullScreenView];
}

- (void)nativeAdDidDismissScreen:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad did dismiss screen");
    [self.adEventDelegate didDismissFullScreenView];
}

- (void)nativeAdWillLeaveApplication:(GADNativeAd *)nativeAd {
    NSLog(@"Native ad will leave application");
    // No corresponding method in GADMediationNativeAdEventDelegate
}

#pragma mark - Private Methods

- (void)processNativeAdAssets {
    // Process icon if available
    if (self.nativeAd.icon && self.nativeAd.icon.image) {
        self.icon = [[GADNativeAdImage alloc] initWithImage:self.nativeAd.icon.image];
    }
    
    // Note: For mediation, we don't need to populate images array as we're using GADNativeAd directly
    // The images property is typically used for custom native ad implementations
    self.images = @[];
}

@end