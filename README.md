# JJStaggeredGridCollectionView

[![CI Status](http://img.shields.io/travis/jjimeno/JJStaggeredGridCollectionView.svg?style=flat)](https://travis-ci.org/jjimeno/JJStaggeredGridCollectionView)
[![Version](https://img.shields.io/cocoapods/v/JJStaggeredGridCollectionView.svg?style=flat)](http://cocoapods.org/pods/JJStaggeredGridCollectionView)
[![License](https://img.shields.io/cocoapods/l/JJStaggeredGridCollectionView.svg?style=flat)](http://cocoapods.org/pods/JJStaggeredGridCollectionView)
[![Platform](https://img.shields.io/cocoapods/p/JJStaggeredGridCollectionView.svg?style=flat)](http://cocoapods.org/pods/JJStaggeredGridCollectionView)

## Example

<p align="center">
<img src="https://github.com/jjimeno/JJStaggeredGridCollectionView/blob/master/imgs/img1.png?raw=true" width=25% height=25%/>
<img src="https://github.com/jjimeno/JJStaggeredGridCollectionView/blob/master/imgs/output.gif?raw=true" width=25% height=25%/>
<img src="https://github.com/jjimeno/JJStaggeredGridCollectionView/blob/master/imgs/img2.png?raw=true" width=25% height=25%/>
</p>

To run the example project, clone the repo, and run `pod install` from the Example directory first.
The example uses [getty images API](http://developers.gettyimages.com/), you need to change the api key for the example to work.

## Usage
JJStaggeredGridCollectionViewLayout is a subclass of [UICollectionViewFlowLayout](https://developer.apple.com/reference/uikit/uicollectionviewflowlayout).   

You can use the following vars of UICollectionViewFlowLayout in JJStaggeredGridCollectionViewLayout:
```swift
open var minimumLineSpacing: CGFloat

open var minimumInteritemSpacing: CGFloat

open var scrollDirection: UICollectionViewScrollDirection // default is UICollectionViewScrollDirectionVertical

open var headerReferenceSize: CGSize

open var footerReferenceSize: CGSize

open var sectionInset: UIEdgeInsets
```

## Installation

JJStaggeredGridCollectionView is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "JJStaggeredGridCollectionView"
```

## License

JJStaggeredGridCollectionView is available under the MIT license. See the LICENSE file for more info.
