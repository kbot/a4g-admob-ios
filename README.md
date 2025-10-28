Ad4Game iOS adapter for Admob.

## Features
- [x] Banner
- [x] Interstitial
- [x] Rewarded
- [x] Native
 
## Requirements

- iOS 12.0+
- GoogleMobileAds 11.0+

## Installation

### CocoaPods

```ruby
pod "Ad4AdmobMediation", :git => "https://github.com/ad4game/a4g-admob-ios.git", :tag => "1.0.2"
pod "Google-Mobile-Ads-SDK", "~> 11.0"
```

### Configure mediation settings for your AdMob ad unit

You need to add Ad4Game placements provided by the Ad4Game team to the mediation configuration as waterfall ad source for your ad unit.

![Waterfall Ad Source](./1679651879220.png)
![Custom Event](./20230407-194253.png)

**Custom Event screen parameters**<br />
**Class Name** : Ad4CustomEvent<br />
**Parameter** : Ad4Game Unit ID<br />
