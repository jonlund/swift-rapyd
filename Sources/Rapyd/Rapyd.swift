private var _rapyd: RapydAPI?

public struct RapydAPI {
	public var secretKey: String
	public var accessKey: String
	

	public enum ServerMode {
		case sandbox
		case production
	}

	public var mode: ServerMode = .sandbox

	
	public static var shared: RapydAPI { _rapyd! }
	
	public static func setShared(_ singleton: RapydAPI) {
		_rapyd = singleton
	}

	public init(secretKey: String, accessKey: String) {
		self.secretKey = secretKey
		self.accessKey = accessKey
    }
}

public enum HTTPMethod: String {
	case GET,POST,PUT,DELETE
}

public protocol RapydEndpoint {
	associatedtype inputType: Codable
	associatedtype outputType: Codable
	associatedtype paramType
	static func endpoint(for inputs: paramType) throws -> String
	static var method: HTTPMethod { get }	// default is post, override if needed
}

extension RapydEndpoint {
	public static var method: HTTPMethod { return .POST }		// default method
}

public struct Empty: Codable {
	public init() { }
}

public struct RapydResponse<T: Codable>: Codable {
	public struct StatusInfo: Codable {
		public enum Status: String, Codable {
			case success = "SUCCESS"
			case error = "ERROR"
		}
		public let error_code: String
		public let status: Status
		public let message: String
		public let response_code: String
		public let operation_id: String
	}
	public let status: StatusInfo
	public let data: T?
}

public struct Country: Codable {
	let id: Int								// Example: 379,
	let name: String						// Example: "Albania",
	let iso_alpha2: String					// Example: "AL",
	let iso_alpha3: String					// Example: "ALB",
	let currency_code: String				// Example: "ALL",
	let currency_name: String				// Example: "Albanian lek",
	let currency_sign: String				// Example: "L",
	let phone_code: String					// Example: "355"
}

public struct GetCountries: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = [Country]
	public typealias paramType = Empty
	static public func endpoint(for inputs: Empty) throws -> String {
		return "data/countries"
	}
}

public struct GetCurrency: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = Output
	public typealias paramType = Params
	static public func endpoint(for inputs: paramType) throws -> String {
		return "issuing/bankaccounts/capabilities?country=\(inputs.country)&currency=\(inputs.currency)"
	}
	
	public struct Params {
		let country: String
		let currency: String
		
		public init(country: String, currency: String) {
			self.country = country
			self.currency = currency
		}
	}

	public struct Output: Codable {
		let country: String
		let supported_currencies: [String]
	}
}



public enum WebhookType: String, Codable {
	case paymentSucceeded = "PAYMENT_SUCCEEDED"
}

public struct WebhookBasic: Codable {
	public let id: String
	public let type: WebhookType
}

public struct WebhookWithData<T:Codable>: Codable {
	public let id: String
	public let type: WebhookType
	public let data: T
}
