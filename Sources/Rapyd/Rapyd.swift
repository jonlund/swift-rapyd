private var _rapyd: Rapyd?

public struct Rapyd {
	private let secretKey: String
	private let accessKey: String

	
	public static var shared: Rapyd? { _rapyd }
	
	public static func setShared(_ singleton: Rapyd?) {
		_rapyd = singleton
	}

	public init(secretKey: String, accessKey: String) {
		self.secretKey = secretKey
		self.accessKey = accessKey
    }
}
