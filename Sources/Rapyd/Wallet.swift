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
	public typealias outputType = [PaymentMethod]
	public typealias paramType = WalletId
	static public func endpoint(for inputs: WalletId) throws -> String {
		return "issuing/bankaccounts/list?ewallet=\(inputs)"
	}
	
	public struct Output: Codable {
		let ewallet: WalletId
		let bank_accounts: [BankAccount]
	}
}


// MARK: - Data Structures

public struct BankAccount: Codable {
	public let account_id: String			// "DK1989000092780494",
	public let account_id_type: String		// "iban",
	public let currency: String				// "EUR",
	public let country_iso: String			// "DK",
	public let issuing_id: String			// "issuing_a59d5518eaa5e3aa342ff633c25d8983"
}
