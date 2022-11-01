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

## Actually Implementing

This code is very generic. Think of it almost like Rapyd's documentation. In order to actually use it
you would have to have code that would be specific to your platform (i.e. iOS or Vapor) so that is not part of this library. However,
it is a really important part of the work.

This really belongs in its own project but until someone else lets me know that they care I will just put it here for reference:

```
//
//  Server+Rapyd.swift
//  Combines Rapyd methods and types to actually make API calls from Vapor Server
//
//  Created by Jon Lund on 7/17/22.
//

import Foundation
import Vapor
import FlashOrderSDK
import Rapyd


fileprivate var encoder = JSONEncoder()

extension RapydEndpoint where inputType == Rapyd.Empty {
	
}

extension RapydEndpoint where paramType == Rapyd.Empty {
	static func endpoint(for inputs: paramType) throws -> String {
		return ""
	}

	static func request(_ inputs: inputType, req: Request) -> EventLoopFuture<outputType> {
		return self.request(.init(), inputs, req: req)
	}
}

extension RapydEndpoint where inputType == Rapyd.Empty {
	static func request(_ params: paramType, req: Request) -> EventLoopFuture<outputType> {
		return self.request(params, .init(), req: req)
	}
}

extension RapydEndpoint where inputType == Rapyd.Empty, paramType == Rapyd.Empty {
	static func request(req: Request) -> EventLoopFuture<outputType> {
		return self.request(.init(), .init(), req: req)
	}
}

extension Rapyd.HTTPMethod {
	var nioMethod: NIOHTTP1.HTTPMethod {
		switch self {
		case .DELETE: 	return NIOHTTP1.HTTPMethod.DELETE
		case .GET:		return NIOHTTP1.HTTPMethod.GET
		case .POST:		return NIOHTTP1.HTTPMethod.POST
		case .PUT:		return NIOHTTP1.HTTPMethod.PUT
		}
	}
}


extension RapydEndpoint {
	static var baseURI: String {
		switch RapydAPI.shared.mode {
		case .sandbox: 		return "https://sandboxapi.rapyd.net/v1/"
		case .production:	return "https://api.rapyd.net/v1/"
		}
	}
	
	fileprivate static func hmac(_ input: String) throws -> String {
		let task = Process()
		task.executableURL = URL(fileURLWithPath: "/usr/bin/openssl")
		task.arguments = [
			"dgst",
			"-sha256WithRSAEncryption",
			"-hmac",
			RapydAPI.shared.secretKey
		]
		let inputData = try input.data(using: .utf8) ?? toss("Can't encode string as UTF8")
		let pipe = Pipe()
		let toWrite = Pipe()
		task.standardOutput = pipe
		task.standardInput = toWrite
		try task.run()
		if #available(macOS 10.15.4, *) {
			try toWrite.fileHandleForWriting.write(contentsOf: inputData)
			try toWrite.fileHandleForWriting.close()
		} else {
			// Fallback on earlier versions
			toWrite.fileHandleForWriting.write(inputData)
			toWrite.fileHandleForWriting.closeFile()
		}
		let data = pipe.fileHandleForReading.readDataToEndOfFile()
		let str = try String(bytes: data, encoding: .utf8) ?? toss("Couldn't get string")
		let trimmed = str.trimmingCharacters(in: .whitespacesAndNewlines)
		let trimmedData = try trimmed.data(using: .utf8) ?? toss("Couldn't re-encode data after trim")
		task.waitUntilExit()
		return trimmedData.base64EncodedString()
	}
	
	
	/// Generates the headers for authentication. Reference: https://docs.rapyd.net/build-with-rapyd/reference/authentication
	fileprivate static func apiHeaders(path: String, body: Data? = nil) throws -> HTTPHeaders {
		// signature = BASE64 ( HASH ( http_method + url_path + salt + timestamp + access_key + secret_key + body_string ) )
		let http_method		= self.method.rawValue.lowercased()
		let url_path		= "/v1/" + path
		let salt			= String.randomId(length: 10, charset: .alphaNumericLowerCase)
		let timestamp		= Date().unixTimestamp.description
		let access_key		= RapydAPI.shared.accessKey
		let secret_key		= RapydAPI.shared.secretKey
		var body_string		= ""
		
		if let data = body,
		   let str = String(bytes: data, encoding: .utf8) {
			body_string = str
		}
		
		let concatenated = http_method
							+ url_path
							+ salt
							+ timestamp
							+ access_key
							+ secret_key
							+ body_string
		
		
		let signed = try hmac(concatenated)

		var headers = HTTPHeaders()
		headers.add(name: .contentType, value: "application/json")
		headers.add(name: "access_key", value: RapydAPI.shared.accessKey)
		headers.add(name: "salt", value: salt)
		headers.add(name: "timestamp", value: timestamp)
		headers.add(name: "signature", value: signed)
		return headers
	}

	static func request(_ params: paramType, _ inputs: inputType, req: Request) -> EventLoopFuture<outputType> {
		let endpoint: String
		do {
			endpoint = try self.endpoint(for: params)
		}
		catch {
			let errormsg = "Could not make endpoint for \(self): \(error.localizedDescription)"
			return req.fail(errormsg)
		}
		let uri: URI = URI(string: self.baseURI + endpoint)
		let future: EventLoopFuture<ClientResponse>

		
		if method != .GET {
			do {
				let encoder = JSONEncoder()
				encoder.outputFormatting = .withoutEscapingSlashes
				let body = try encoder.encode(inputs)
				let headers = try apiHeaders(path: endpoint, body: body)
				future = req.client.send(self.method.nioMethod, headers: headers, to: uri, beforeSend: { (request) in
					let buf = ByteBuffer(data: body)
					request.body = buf
					req.log("curl \(headers.curlString) -X \(method.nioMethod.string) -d '\(buf.allAsString())' \(uri)", synopsis: method.nioMethod.string + " rapyd.com/" + endpoint, src: .server, dst: .rapyd)
				})
			}
			catch {
				return req.fail("Unable to encode inputs: \(error.localizedDescription)")
			}
		}
		else {
			do {
				let headers = try apiHeaders(path: endpoint)
				future = req.client.send(method.nioMethod, headers: headers, to: uri)
				req.log("curl \(headers.curlString) \(uri)", synopsis: "GET rapyd.com/" + endpoint, src: .server, dst: .rapyd)
			}
			catch {
				return req.fail("Unable to make request headers: `\(error)`")
			}
		}

		return future.flatMapThrowing { response in
			// if dev...
			let status: String = "\(response.status.code) \(response.status.reasonPhrase)"
			if let body = response.body {
				req.log(body.allAsString().trimmingCharacters(in: .whitespacesAndNewlines), synopsis: status, src: .rapyd, dst: .square)
			}
			else if response.status != .ok {
				req.log(response.status.reasonPhrase, synopsis: status, src: .rapyd, dst: .server, logLevel: .error)
			}
			else {
				req.log("(No body)", synopsis: status, src: .rapyd, dst: .server, logLevel: .warning)
			}
			
			let decoded: RapydResponse<outputType>
			do {
				decoded = try response.content.decode(RapydResponse<outputType>.self)
			}
			catch {
				throw "Unable to get a proper response. Decoding error is: `\(error)`"
			}
			
			guard decoded.status.status != .error else {
				throw "API status says error. message: `\(decoded.status.message.nonBlankString ?? decoded.status.error_code)`"
			}
			
			guard let data = decoded.data else {
				throw "unable to get any value from decoded object. message: `\(decoded.status.message)`"
			}
			return data
		}
	}
}

extension RapydResponse: Content {}
extension Rapyd.WebhookBasic: Content {}

```


## Tests

Here are a bunch of tests that can be run from Vapor:

```
	func testRapydAPI() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try Rapyd.GetCountries.request(.init(), .init(), req: request).wait()
		XCTAssert(result.count > 0)
	}

	func testRapydAPICurrency() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try Rapyd.GetCurrency.request(
			.init(country: "US", currency: "USD"),
			.init(), req: request).wait()
		print("RESULT: \(result)")
	}
	
	func testRapydCheckoutPageCreate() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let amount: CodableDecimal = .init(floatValue: 100.0, decimalPlaces: 2)
		var inputs: CheckoutPage = .init(amount: amount, country: "US", currency: "USD")
		inputs.description = "Unit Test"
		inputs.complete_checkout_url = "https://eacf-172-58-43-119.ngrok.io/rapyd/checkout/complete"
		inputs.cancel_checkout_url = "https://eacf-172-58-43-119.ngrok.io/rapyd/checkout/cancel"
		let result = try CreateCheckoutPage
			.request(inputs, req: request)
			.wait()
		print("RESULT: \(result)")
	}
	
	func testRapydCheckoutPageFetch() throws {
		let id = "checkout_b6d7ca08af4196a651ba1648e4d41857"
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try GetCheckoutPage.request(id, req: request)
			.wait()
		print("RESULT: \(result)")
	}

	func testRapydAPIPaymentMethods() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try GetPaymentMethods
			.request(.init(country: "US", currency: "USD"), req: request)
			.wait()
		print("RESULT: \(result)")
	}

	func testRapydAPIBankAccounts() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try ListVirtualAccounts
			.request("ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52", req: request)
			.wait()
		print("RESULT: \(result)")
	}

	func testRapydAPIPayoutMethod() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try GetPayoutMethodTypes
			.request(
				.init(
					beneficiary_country: "US",
					beneficiary_entity_type: .company,
					category: .bank,
					payout_currency: "USD",
					sender_country: "US",
					sender_currency: "USD",
					sender_entity_type: .company),
				req: request)
			.wait()
		print("RESULT: \(result)")
	}

	func testRapydAPIPayoutRequiredFields() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try GetPayoutRequiredFieds
			.request(
				.init(
					payout_method_type: .us_standard_ach_bank,
					beneficiary_country: "US",
					beneficiary_entity_type: .company,
					payout_amount: 100.0,
					payout_currency: "USD",
					sender_country: "US",
					sender_currency: "USD",
					sender_entity_type: .company
				),
				req: request)
			.wait()
		print("RESULT: \(result)")
	}

	func testRapydAPIPayout() throws {
		let request = Request(application: app, on: app.client.eventLoop)
		let result = try CreatePayout
			.request(
				.init(
					beneficiary:
							.init(
								company_name: "XYZFoodTruck",
								bank_account_type: .CHECKING,
								account_number: 123456789,
								aba: 124000054
							),
					beneficiary_country: "US",
					beneficiary_entity_type: .company,
					//confirm_automatically: "XXXXXX",
					description: "Payout from Flash Order",
					//expiration: "XXXXXX",
					ewallet: "ewallet_df9f3d6b00d13bf35cf8dc8a844d3e52",
					merchant_reference_id: "MY_REFERENCE_ID",
					//metadata: "XXXXXX",
					payout_amount: "43.23",
					payout_currency: "USD",
					//payout_fees: "XXXXXX",
					payout_method_type: .us_standard_ach_bank,
					sender: .init(company_name: "Mana Mobile, LLC"),
					//sender_amount: "XXXXXX",
					sender_country: "US",
					sender_currency: "USD",
					sender_entity_type: .company,
					statement_descriptor: "Disbursement from Flash Order Partnership"
				),
				req: request)
			.wait()
		print("RESULT: \(result)")
	}
```

## Contributing

If anyone is interested in this let me know and I'll clean it up and make it nice! There is also some more code you would want to have to use the methods in iOS or on a server. (I use Vapor on Linux)
