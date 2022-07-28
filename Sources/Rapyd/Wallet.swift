//
//  File.swift
//  
//
//  Created by Jon Lund on 7/19/22.
//


// MARK: - Methods


public typealias WalletId = String

public struct ListVirtualAccounts: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = Output
	public typealias paramType = WalletId
	static public func endpoint(for inputs: WalletId) throws -> String {
		return "issuing/bankaccounts/list?ewallet=\(inputs)"
	}
	
	public struct Output: Codable {
		public let ewallet: WalletId
		public let bank_accounts: [BankAccount]
	}
}


public struct GetWallet: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = Wallet
	public typealias paramType = WalletId
	static public func endpoint(for inputs: WalletId) throws -> String {
		return "user/\(inputs)"
	}
}

public struct GetWalletTransactions: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = [Wallet.Transaction]
	public typealias paramType = Params
	static public func endpoint(for inputs: Params) throws -> String {
		return "user/\(inputs.walletId)/transactions"//?\(inputs)"
	}
	
	public struct Params {
		public let walletId: String
		public init(walletId: String) {
			self.walletId = walletId
		}
	}
}

public struct GetPayoutMethodTypes: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = [PayoutMethod]
	public typealias paramType = Params
	static public func endpoint(for inputs: Params) throws -> String {
		return "payouts/supported_types?" + inputs.queryString
	}

	public struct Params {
		public let beneficiary_country: String?
		public let beneficiary_entity_type: EntityType?
		public let category: PayoutType?
		public let ending_before: String?
		public let is_cancelable: Bool?
		public let is_expirable: String?
		public let is_location_specific: String?
		public let limit: String?
		public let payout_currency: String?
		public let sender_country: String?
		public let sender_currency: String?
		public let sender_entity_type: EntityType?
		public let starting_after: String?
		
		public init(beneficiary_country: String? = nil, beneficiary_entity_type: EntityType? = nil, category: PayoutType? = nil, ending_before: String? = nil, is_cancelable: Bool? = nil, is_expirable: String? = nil, is_location_specific: String? = nil, limit: String? = nil, payout_currency: String? = nil, sender_country: String? = nil, sender_currency: String? = nil, sender_entity_type: EntityType? = nil, starting_after: String? = nil) {
			self.beneficiary_country 		= beneficiary_country
			self.beneficiary_entity_type 	= beneficiary_entity_type
			self.category 					= category
			self.ending_before 				= ending_before
			self.is_cancelable 				= is_cancelable
			self.is_expirable 				= is_expirable
			self.is_location_specific 		= is_location_specific
			self.limit 						= limit
			self.payout_currency 			= payout_currency
			self.sender_country 			= sender_country
			self.sender_currency 			= sender_currency
			self.sender_entity_type 		= sender_entity_type
			self.starting_after 			= starting_after
		}
		
		var queryString: String {
			var values: [String] = []
			if let v = beneficiary_country			{ values.append("beneficiary_country=\(v)") }
			if let v = beneficiary_entity_type		{ values.append("beneficiary_entity_type=\(v.rawValue)") }
			if let v = category						{ values.append("category=\(v.rawValue)") }
			if let v = ending_before				{ values.append("ending_before=\(v)") }
			if let v = is_cancelable				{ values.append("is_cancelable=\(v)") }
			if let v = is_expirable					{ values.append("is_expirable=\(v)") }
			if let v = is_location_specific			{ values.append("is_location_specific=\(v)") }
			if let v = limit						{ values.append("limit=\(v)") }
			if let v = payout_currency				{ values.append("payout_currency=\(v)") }
			if let v = sender_country				{ values.append("sender_country=\(v)") }
			if let v = sender_currency				{ values.append("sender_currency=\(v)") }
			if let v = sender_entity_type			{ values.append("sender_entity_type=\(v.rawValue)") }
			if let v = starting_after				{ values.append("starting_after=\(v)") }
			return values.joined(separator: "&")
		}
	}


}




public struct GetPayoutRequiredFieds: RapydEndpoint {
	public static var method: HTTPMethod { .GET }
	public typealias inputType = Empty
	public typealias outputType = AnyCodable
	public typealias paramType = Params
	static public func endpoint(for inputs: Params) throws -> String {
		return "payouts/\(inputs.payout_method_type.rawValue)/details?" + inputs.queryString
	}
	
	public struct Params {
		public let payout_method_type: MethodType
		public let beneficiary_country: String
		public let beneficiary_entity_type: EntityType
		public let payout_amount: Float
		public let payout_currency: String
		public let sender_country: String
		public let sender_currency: String
		public let sender_entity_type: EntityType

		public init(payout_method_type: MethodType, beneficiary_country: String, beneficiary_entity_type: EntityType, payout_amount: Float, payout_currency: String, sender_country: String, sender_currency: String, sender_entity_type: EntityType) {
			self.payout_method_type = payout_method_type
			self.beneficiary_country = beneficiary_country
			self.beneficiary_entity_type = beneficiary_entity_type
			self.payout_amount = payout_amount
			self.payout_currency = payout_currency
			self.sender_country = sender_country
			self.sender_currency = sender_currency
			self.sender_entity_type = sender_entity_type
		}
		
		var queryString: String {
			var values: [String] = []
			values.append("beneficiary_country=\(beneficiary_country)")
			values.append("beneficiary_entity_type=\(beneficiary_entity_type.rawValue)")
			values.append("payout_amount=\(payout_amount)")
			values.append("payout_currency=\(payout_currency)")
			values.append("sender_country=\(sender_country)")
			values.append("sender_currency=\(sender_currency)")
			values.append("sender_entity_type=\(sender_entity_type.rawValue)")
			return values.joined(separator: "&")
		}
	}
}

public struct CreatePayout: RapydEndpoint {
	public static var method: HTTPMethod { .POST }
	public typealias inputType = Input
	public typealias outputType = AnyCodable
	public typealias paramType = Empty
	static public func endpoint(for inputs: Empty) throws -> String {
		return "payouts"
	}
	
	public struct Input: Codable {
		public let beneficiary: PayoutBeneficiary
		public let beneficiary_country: String?
		public let beneficiary_entity_type: EntityType
		public let confirm_automatically: Bool?
		public let description: String?
		public let expiration: String?
		public let ewallet: String?
		public let merchant_reference_id: String?
		public let metadata: AnyCodable?
		public let payout_amount: String
		public let payout_currency: String
		public let payout_fees: [AnyCodable]?
		public let payout_method_type: MethodType?
		public let sender: PayoutSender
		public let sender_amount: Float?
		public let sender_country: String
		public let sender_currency: String
		public let sender_entity_type: EntityType
		public let statement_descriptor: String?
		
		public init(
			beneficiary: PayoutBeneficiary,
			beneficiary_country: String? = nil,
			beneficiary_entity_type: EntityType,
			confirm_automatically: Bool? = nil,
			description: String? = nil,
			expiration: String? = nil,
			ewallet: String? = nil,
			merchant_reference_id: String? = nil,
			metadata: AnyCodable? = nil,
			payout_amount: String,
			payout_currency: String,
			payout_fees: [AnyCodable]? = nil,
			payout_method_type: MethodType? = nil,
			sender: PayoutSender,
			sender_amount: Float? = nil,
			sender_country: String,
			sender_currency: String,
			sender_entity_type: EntityType,
			statement_descriptor: String? = nil
		) {
			self.beneficiary = beneficiary
			self.beneficiary_country = beneficiary_country
			self.beneficiary_entity_type = beneficiary_entity_type
			self.confirm_automatically = confirm_automatically
			self.description = description
			self.expiration = expiration
			self.ewallet = ewallet
			self.merchant_reference_id = merchant_reference_id
			self.metadata = metadata
			self.payout_amount = payout_amount
			self.payout_currency = payout_currency
			self.payout_fees = payout_fees
			self.payout_method_type = payout_method_type
			self.sender = sender
			self.sender_amount = sender_amount
			self.sender_country = sender_country
			self.sender_currency = sender_currency
			self.sender_entity_type = sender_entity_type
			self.statement_descriptor = statement_descriptor
		}
	}
}


// MARK: - Data Structures

public enum BankAccountType: String, Codable {
	case CHECKING, SAVING
}

public struct PayoutBeneficiary: Codable {
	public let company_name: String
	public let bank_account_type: BankAccountType
	public let account_number: Int
	public let aba: Int
	
	public init(company_name: String, bank_account_type: BankAccountType, account_number: Int, aba: Int) {
		self.company_name = company_name
		self.bank_account_type = bank_account_type
		self.account_number = account_number
		self.aba = aba
	}
}

public struct PayoutSender: Codable {
	public let company_name: String
	
	public init(company_name: String) {
		self.company_name = company_name
	}
}

public enum PayoutType: String, Codable {
	case bank, card, cash, rapyd_ewallet, ewallet
}

public enum EntityType: String, Codable {
	case individual, company
}

public struct AmountRange: Codable {
	public let maximum_amount: Int?
	public let minimum_amount: Int?
	public let payout_currency: String
}

public enum MethodType: String, Codable {
	case us_achnonus_bank
	case us_ach_bank
	case us_general_bank
	case us_sameday_ach_bank
	case us_standard_ach_bank
	case us_wires_bank
	case xx_swift_bank
}

public struct PayoutMethod: Codable {
	public let payout_method_type: MethodType
	public let name: String
	public let is_cancelable: Int
	public let is_expirable: Int
	public let is_location_specific: Int
	public let status: Int
	public let image: String
	public let category: PayoutType
	public let beneficiary_country: String
	public let sender_country: String
	public let payout_currencies: [String]
	public let sender_entity_types: [EntityType]
	public let beneficiary_entity_types: [EntityType]
	public let amount_range_per_currency: [AmountRange]
	public let minimum_expiration_seconds: Int?
	public let maximum_expiration_seconds: Int?
	public let sender_currencies: [String]
}

public struct Wallet: Codable {

	public struct Account: Codable {
		public let id: 					String?				//"254965b6-9aac-48ac-b828-5b982ad449a1",
		public let currency: 			String?				//"EUR",
		public let alias: 				String?				//"EUR",
		public let balance: 			Float?				//50,
		//public let received_balance:	Int?				//0,
		//public let on_hold_balance: 	Int?				//0,
		//public let reserve_balance: 	Int?				//0,
		//public let limits: 				String?				//null,
		//public let limit: 				String?				//null
	}

	public let id: 						String				// "ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52",
	public let phone_number: 			String?				// "+523093269044",
	public let email: 					String?				// "Romonowski@mail.com",
	public let first_name: 				String?				// 	null,
	public let last_name: 				String?				// "Romonowski",
	public let status: 					String?				// "ACT",
	public let accounts: 				[Account]
	public let verification_status:		String?				// "not verified",
	public let type:					String?				// "person",
	//public let metadata:				String?				// 	public let ewallet_reference_id					String?				// null,
	public let category:				String?				//  null,
	//public let contacts:									// "data": [
	//				{
	//					"id": "cont_fd3844e20abf8163ebdb95eb26382f26",
	//					"first_name": "",
	//					"last_name": "Romonowski",
	//					"middle_name": "",
	//					"second_last_name": "",
	//					"gender": "not_applicable",
	//					"marital_status": "not_applicable",
	//					"house_type": "",
	//					"contact_type": "personal",
	//					"phone_number": "+523093269044",
	//					"email": "Romonowski@mail.com",
	//					"identification_type": "",
	//					"identification_number": "",
	//					"issued_card_data": {
	//						"preferred_name": "",
	//						"transaction_permissions": "",
	//						"role_in_company": ""
	//					},
	//					"date_of_birth": null,
	//					"country": "",
	//					"nationality": null,
	//					"address": null,
	//					"ewallet": "ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52",
	//					"created_at": 1656613816,
	//					"metadata": {},
	//					"business_details": null,
	//					"compliance_profile": 0,
	//					"verification_status": "not verified",
	//					"send_notifications": false,
	//					"mothers_name": ""
	//				}
	//			],
	//			"has_more": false,
	//			"total_count": 1,
	//			"url": "/v1/ewallets/ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52/contacts"
	//		}
}

extension Wallet {
	public struct Transaction: Codable {
		public enum TransactionType: String, Codable, CustomStringConvertible {
			case add_funds
			case payout_funds_out
			case bank_issuing_in
			case payout_funds_in
			
			public var description: String {
				switch self {
				case .add_funds:				return "Deposit"
				case .payout_funds_out:			return "Disbursement"
				case .bank_issuing_in:			return "Transfer from Bank"
				case .payout_funds_in:			return "Cancelled Payout"
				}
			}
			
			public var isDebit: Bool {
				switch self {
				case .add_funds, .payout_funds_in, .bank_issuing_in:
					return true
				case .payout_funds_out:
					return false
				}
			}
		}
		
		public let id: String						// "wt_694be3b82d88fa1a234c3a0112d38a3b",
		public let currency: String					// "EUR",
		public let amount: Float?					// 50,
		public let ewallet_id: String				// "ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52",
		public let type: TransactionType			// "add_funds",
		public let balance_type: String?			// "available_balance",
		public let balance: Float?					// 50,
		public let created_at: Int					// 1656613817,
		public let status: String?					// "CLOSED",
		public let reason: String?					// "",
		//public let metadata: String?				// {}
	}
}

public struct BankAccount: Codable {
	public let account_id: String			// "DK1989000092780494",
	public let account_id_type: String		// "iban",
	public let currency: String				// "EUR",
	public let country_iso: String			// "DK",
	public let issuing_id: String			// "issuing_a59d5518eaa5e3aa342ff633c25d8983"
}
