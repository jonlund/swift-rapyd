# Swift Rapyd

Swift Rapyd is a pure swift library for accessing Rapyd's API

## Using Swift Rapyd

 Swift Rapyd is available as a Swift Package Manager package. To use it, add the following dependency in your `Package.swift`:
 
 ```swift
// swift-crypto 1.x and 2.x are almost API compatible, so most clients should
// allow either
.package(url: "https://github.com/jonlund/swift-rapyd.git", "1.0.0" ..< "3.0.0"),
```

and to your target, add `Rapyd` to your dependencies. You can then `import Rapyd` in the files where you want to access it.

## Implementation

This can be used with the web framework Vapor. 


## Contributing

If anyone is interested in this let me know and I'll clean it up and make it nice! There is also some more code you would want to have to use the methods in iOS or on a server. (I use Vapor on Linux)
