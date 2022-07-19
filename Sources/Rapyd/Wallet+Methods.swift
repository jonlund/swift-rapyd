//
//  Wallet.swift
//  
//
//  Created by Jon Lund on 7/19/22.
//


public typealias WalletId = String

public struct ListBankAccounts: RapydEndpoint {
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
