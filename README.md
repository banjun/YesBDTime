# YesBDTime

[![Version](https://img.shields.io/cocoapods/v/YesBDTime.svg?style=flat)](https://cocoapods.org/pods/YesBDTime)
[![License](https://img.shields.io/cocoapods/l/YesBDTime.svg?style=flat)](https://cocoapods.org/pods/YesBDTime)
[![Platform](https://img.shields.io/cocoapods/p/YesBDTime.svg?style=flat)](https://cocoapods.org/pods/YesBDTime)

## Usage

With Mac Blu-ray Player playing:

```swift
let ybt = YesBDTime()
ybt.callback = { t in
    NSLog("%@", "BD Time = \(t)")
}
ybt.capture(repeatedlyWith: 1)
```

## Installation

```ruby
pod 'YesBDTime' # with repo specifier
```

## Author

banjun

## License

YesBDTime is available under the MIT license. See the LICENSE file for more info.  

MNIST coreml model is authored by Philipp Gabriel and is available under the MIT license. <https://github.com/likedan/Awesome-CoreML-Models>
