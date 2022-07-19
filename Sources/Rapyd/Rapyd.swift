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


public struct GetPaymentMethods: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = [PaymentMethod]
	public typealias paramType = Params
	static public func endpoint(for inputs: paramType) throws -> String {
		return "payment_methods/country?country=\(inputs.country)&currency=\(inputs.currency)"
	}
	
	public struct Params {
		let country: String
		let currency: String
		
		public init(country: String, currency: String) {
			self.country = country
			self.currency = currency
		}
	}
	
	public struct PaymentMethod: Codable {
		let type: String
		let name: String
		let category: String
		let image: String
		let country: String
		let payment_flow_type: String
		let currencies: [String]
		let status: Int
		//			let is_cancelable: Bool
		//			let payment_options: []
		//			let is_expirable: Bool
		//			let is_online: Bool
		//			let is_refundable: Bool
		//			let minimum_expiration_seconds: Int
		//			let maximum_expiration_seconds: Int
		//			let virtual_payment_method_type: String
		//			let is_virtual: Bool
		//			let multiple_overage_allowed: Bool
		//			let amount_range_per_currency: [
		//				{
		//					"currency": "USD",
		//					"maximum_amount": null,
		//					"minimum_amount": null
		//				}
		//			]
		//			let is_tokenizable: Bool
		//			let supported_digital_wallet_providers: []
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

public struct PaymentMethodData: Codable {
	public let id: String							// "other_46330fec2963b746f406378601de1ee5",
	public let type: String							// "us_sameday_ach_bank",
	public let image: String						// "",
	public let category: String						// "bank_transfer",
	//public let metadata: String						// {},
	public let bic_swift: String					// "",
	public let next_action: String					// "not_applicable",
	public let webhook_url: String					// "",
	public let account_type: String					// "CHECKING",
	public let account_last4: String				// "",
	public let account_number: String				// "123456789",
	public let routing_number: String				// "124000054",
	public let proof_of_authorization: Bool			// false,
	public let supporting_documentation: String		// ""
}

public struct Payment: Codable {
	public let id: String
	public let paid: Bool
	public let amount: Int
	public let country_code: String
	public let description: String
	public let ewallet_id: String
	public let captured: Bool
	public let created_at: Int
	public let expiration: Int
	public let currency_code: String
	public let customer_token: String					// "cus_a4117bd598c8050f6da4b278c5f5affc",
	public let payment_method: String					// "other_46330fec2963b746f406378601de1ee5",
	public let receipt_number: String					// "",
	public let transaction_id: String					// "",
	public let failure_message: String					// "",
	public let initiation_type: String					// "customer_present",
	public let original_amount: Int						// 743,
	public let refunded_amount: Int						// 0,
	public let error_payment_url: String				// "https://sandboxcheckout.rapyd.net/thank-you-failed/checkout_5f833719c82be8ffb5da14ee85c92942",
	public let payment_method_data: PaymentMethodData
	public let payment_method_type: String				// "us_sameday_ach_bank",
	public let complete_payment_url: String				// "https://sandboxcheckout.rapyd.net/thank-you-success/checkout_5f833719c82be8ffb5da14ee85c92942",
	public let statement_descriptor: String				// "N/A",
	public let merchant_reference_id: String			// "USWNTvsCANADA",
	public let payment_method_type_category: String		// "bank_transfer"
	//"payment_method_options": {},
	//"merchant_requested_amount": null,
	//"merchant_requested_currency": null,
	//"remitter_information": {},

}

/*
{
	"id": "wh_c5304a1a6d0d9d73bfd440afa6eba1b4",
	"type": "PAYMENT_SUCCEEDED",
	"data": {
		"id": "payment_dcc7df2f5bb913d70d0659b8e67c4638",
		"mid": "",
		"paid": false,
		"order": null,
		"amount": 0,
		"escrow": null,
		"status": "ACT",
		"address": null,
		"dispute": null,
		"fx_rate": 1,
		"invoice": "",
		"outcome": null,
		"paid_at": 0,
		"refunds": null,
		"captured": true,
		"ewallets": [
			{
				"amount": 743,
				"percent": 100,
				"ewallet_id": "ewallet_16a7d52901c805bc41284d0fcf0caa61",
				"refunded_amount": 0
			}
		],
		"metadata": {},
		"refunded": false,
		"flow_type": "",
		"created_at": 1658198483,
		"error_code": "",
		"ewallet_id": "ewallet_16a7d52901c805bc41284d0fcf0caa61",
		"expiration": 1659408083,
		"fixed_side": "",
		"is_partial": false,
		"description": "Payment via Checkout",
		"next_action": "pending_confirmation",
		"country_code": "US",
		"failure_code": "",
		"instructions": [
			{
				"name": "instructions",
				"steps": [
					{
						"step1": "Payments received and processed before 4:00PM EST will be credited within the same day"
					}
				]
			}
		],
		"payment_fees": null,
		"redirect_url": "",
		"visual_codes": {},
		"cancel_reason": null,
		"currency_code": "USD",
		"group_payment": "",
		"receipt_email": "",
		"textual_codes": {},
		"customer_token": "cus_a4117bd598c8050f6da4b278c5f5affc",
		"payment_method": "other_46330fec2963b746f406378601de1ee5",
		"receipt_number": "",
		"transaction_id": "",
		"failure_message": "",
		"initiation_type": "customer_present",
		"original_amount": 743,
		"refunded_amount": 0,
		"error_payment_url": "https://sandboxcheckout.rapyd.net/thank-you-failed/checkout_5f833719c82be8ffb5da14ee85c92942",
		"payment_method_data": {
			"id": "other_46330fec2963b746f406378601de1ee5",
			"type": "us_sameday_ach_bank",
			"image": "",
			"category": "bank_transfer",
			"metadata": {},
			"bic_swift": "",
			"next_action": "not_applicable",
			"webhook_url": "",
			"account_type": "CHECKING",
			"account_last4": "",
			"account_number": "123456789",
			"routing_number": "124000054",
			"proof_of_authorization": false,
			"supporting_documentation": ""
		},
		"payment_method_type": "us_sameday_ach_bank",
		"complete_payment_url": "https://sandboxcheckout.rapyd.net/thank-you-success/checkout_5f833719c82be8ffb5da14ee85c92942",
		"remitter_information": {},
		"statement_descriptor": "N/A",
		"merchant_reference_id": "USWNTvsCANADA",
		"payment_method_options": {},
		"merchant_requested_amount": null,
		"merchant_requested_currency": null,
		"payment_method_type_category": "bank_transfer"
	},
	"trigger_operation_id": "64577803-60a0-4c77-92f6-8159d76ba223",
	"status": "RET",
	"created_at": 1658198483
}
*/

