//
//  File.swift
//  
//
//  Created by Jon Lund on 7/19/22.
//



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
