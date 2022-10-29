//
//  CheckoutPage.swift
//  
//
//  Created by Jon Lund on 10/29/22.
//

public struct CodableDecimal: Codable {
	let decimalPlaces: Int?
	public let value: Float
	
	public init(floatValue: Float, decimalPlaces: Int) {
		self.value = floatValue
		self.decimalPlaces = decimalPlaces
	}
	
	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let iValue = try? container.decode(Int.self) {
			value = Float(iValue)
		}
		else {
			value = try container.decode(Float.self)
		}
		decimalPlaces = nil
	}
	
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		let places: Int = decimalPlaces ?? 2
		let str = String(format: "%.0\(places)f", value)
		if str.hasSuffix(".00") {
			let iVal = Int(value + 0.00000001)
			try container.encode(iVal)
		}
		else {
			try container.encode(str)
		}
	}
}


/// Data structure for a checkout page (see https://docs.rapyd.net/build-with-rapyd/reference/checkout-page#create-checkout-page)
public struct CheckoutPage: Codable {
	
	/// The amount of the payment, in units of the currency defined in currency. Decimal.
	public let amount: CodableDecimal
	
	/// The two-letter ISO 3166-1 ALPHA-2 code for the country. Uppercase.
	public let country: String
	
	/// Three-letter ISO 4217 code for the currency used in the amount field. Uppercase. In FX transactions, when fixed_side is buy, it is the currency received by the merchant. When fixed_side is sell, it is the currency charged to the buyer.
	public let currency: String
	
	/// URL where the customer is redirected when checkout is successful. This page can be set dynamically for each generated checkout page as it overrides the fallback URL that was set in the Client Portal.
	public var complete_checkout_url: String?
	
	/// URL where the customer is redirected after pressing Back to Website to exit the hosted page. This URL overrides the merchant_website URL. Does not support localhost URLs.
	public var cancel_checkout_url: String?
	
	/// ID of the Rapyd Checkout page.
	public let id: String?
	
	/// // ID of the 'customer' object. String starting with cus_. Relevant when the customer is already signed up and stored on the Rapyd platform. 	 This field is required for certain production mode payment methods.
	public var customer: String?
	
	///Determines when the payment is processed for capture. Relevant to card payments.
	/// * True: Capture the payment immediately. This is the default.
	/// * False: Authorize the payment, then capture some or all of the payment at a later time, when the merchant runs the Capture Payment method.
	///
	/// Note: Some card payment methods do not support delayed capture.
	public var capture: Bool?
	
	/// Describes the cart items that the customer is purchasing. These items are displayed at the checkout page. Contains the following fields for each cart item:
	public var cart_items: [CartItem]?
	
	/// URL where the customer is redirected after completing the payment instructions on the third party site. Relevant to bank redirect payment methods. Does not support localhost URLs.
	public var complete_payment_url: String?
	
	/// Describes customizations of the page as it appears to the customer. See Custom Elements Object.
	public var custom_elements: AnyCodable?
	
	/// Description of the payment transaction. To display the description, set display_description to true in custom_elements. See Custom Elements Object.
	public var description: String?
	
	/// URL where the customer is redirected after an error occurs on the third-party site. Relevant to bank redirect payment methods. Does not support localhost URLs.
	public var error_payment_url: String?
	
	/// Determines whether the payment is held in escrow for later release.
	public var escrow: Bool?
	
	/// Determines the number of days after creation of the payment that funds are released from escrow. Funds are released at 5:00 pm GMT on the day indicated. Integer, range: 1-90.
	public var escrow_release_days: Int?
	
	/// ID of the wallet that the money is paid into. String starting with ewallet_. Relevant for specifying a single wallet in the request.
	public var ewallet: String?
	
	/// Specifies one or more wallets that the money is collected into. 	 See Wallets Array.
	public var ewallets: [String]?
	
	/// Time when the payment expires if it is not completed, in Unix time. When both expiration and payment_expiration are set, the payment expires at the earlier time. Default is 14 days after creation of the checkout page.
	public var expiration: Int?
	
	/// Indicates whether the FX rate is fixed for the buy side (seller) or for the sell side (buyer).
	/// One of the following values:
	/// * buy - The checkout page shows the currency that the seller (merchant) receives for goods or services. This is the default. For example, a US-based merchant wants to charge 100 USD. The buyer (customer) pays the amount in MXN that converts to 100 USD.
	/// * sell - The checkout page shows the currency that the buyer is charged with to purchase goods or services from the seller. For example, a US-based merchant wants to charge a buyer 2,000 MXN and will accept whatever amount in USD that is converted from 2,000 MXN.
	public var fixed_side: String?
	
	/// Determines the default language of the hosted page.
	/// The values are documented in Hosted Page Language Support.
	/// * When this parameter is null, the language of the user's browser is used.
	/// * If the language of the user's browser cannot be determined, the default language is English.
	public var language: String?
	
	/// Reserved. Default is 'Rapyd'.
	public private(set) var merchant_alias: String?
	
	/// Color of the action button on the hosted page. Response only. To configure this field, use the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_color: String?
	
	
	/// Contact details for customer support, containing the following fields:
	/// * email - Email address.
	/// * url - URL for the client's customer support service.
	/// * phone_number - Phone number for contacting the client's customer support service.
	/// Response only.
	///
	/// To configure these fields, use the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_customer_support: AnyCodable?
	
	
	/// URL for the image of the client's logo. Response only. To configure this field, use the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_logo: String?
	
	/// A string that represents the text on the main Call to Action (CTA) button.
	/// One of the following:
	/// * place_your_order - Place Your Order. This is the default.
	/// * pay_now - Pay Now.
	/// * make_payment - Make Payment.
	/// * buy - Buy.
	/// * donate - Donate.
	/// Response only.
	///
	/// To configure this button, use the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_main_button: String?
	
	/// URL for the client's privacy policy. Response only. To configure this field, use the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_privacy_policy: String?
	
	/// Identifier for the transaction. Defined by the merchant. Can be used for reconciliation.
	public var merchant_reference_id: String?
	
	/// URL for the client's terms and conditions. Response only.
	public private(set) var merchant_terms: String?
	
	/// The URL where the customer is redirected after exiting the hosted page.
	///Relevant when one or both of the following fields is unset:
	///* cancel_checkout_url
	///* complete_checkout_url
	///
	///Response only.
	///
	///To configure this field, use the Fallback URL field in the Client Portal. See Customizing Your Hosted Page.
	public private(set) var merchant_website: String?
	
	
	/// A JSON object defined by the client.
	public var metadata: AnyCodable?
	
	/// End of the time when the customer can use the hosted page, in Unix time. If page_expiration is not set, the checkout page expires 14 days after creation. Range: 1 minute to 30 days.
	public var page_expiration: Int?
	
	
	/// Describes the payment that will result from the hosted page. See Payment Object for details. The id and status values are null until the customer successfully submits the information on the hosted page. Response only.
	public private(set) var payment: Payment?
	
	/// Length of time for the payment to be completed after it is created, measured in seconds. When both expiration and payment_expiration are set, the payment expires at the earlier time.
	public var payment_expiration: Int?
	
	/// Describes the fees that can be charged for a payment transaction. See Payment Fees Object.
	public var payment_fees: AnyCodable?
	
	
	///Object that describes the payment method. Contains the following fields:
	/// * type - The type of the payment method. Required.
	/// * fields - Contains the fields that are required for the payment method. See Get Payment Method Required Fields.
	/// * name - Name of the payment method.
	/// * address - 'Address' object that describes the address associated with the payment. See Address Object. Do not use an address ID.
	/// * metadata - 'Metadata' object defined by the merchant. See Metadata Object.
	///
	/// Note: This behavior is different from Create Payment.
	public var payment_method: AnyCodable?
	
	///The type of the payment method. For example, it_visa_card.
	///
	/// To get a list of payment methods for a country, use List Payment Methods by Country.
	///
	/// See Configuring List of Payment Methods.
	/// payment_method_type_categories	array of strings	A list of the categories of payment method that are supported on the checkout page. The categories appear on the page in the order provided. One or more of the following:
	/// * bank_redirect
	/// * bank_transfer
	/// * card
	/// * cash
	/// * ewallet
	///
	/// See Configuring List of Payment Methods.
	public var payment_method_type: String?
	
	/// List of payment methods that are excluded from display on the checkout page.
	public var payment_method_types_exclude: [String]?
	
	/// List of payment methods that are displayed on the checkout page. The payment methods appear on the page in the order provided.
	public var payment_method_types_include: [String]?
	
	/// URL of the checkout page that is shown to the customer.
	public private(set) var redirect_url: String?
	
	/// When fixed_side is sell, it is the currency received by the merchant.
	/// When fixed_side is buy, it is the currency charged to the buyer (customer). The checkout page displays the following information:
	/// * The original amount and currency.
	/// * The converted amount in the requested currency.
	/// * The exchange rate.
	///
	/// Three-letter ISO 4217 code.
	///
	/// Relevant to payments with FX.
	public var requested_currency: String?
	
	public enum Status: String, Codable {
		/// The hosted page was created.
		case NEW
		/// Done. The payment was completed.
		case DON
		/// The hosted page expired.
		case EXP
		/// Creation of the payment is still in progress.
		case INP
		/// Rapyd Protect blocked the payment.
		case DEC
	}
	
	/// Status of the hosted page. One of the following:
	public private(set) var status: Status?
	
	/// Time of creation of the checkout page, in Unix time. Response only.
	public private(set) var timestamp: Int?
	

	
	public init(amount: CodableDecimal, country: String, currency: String) {
		self.amount		= amount
		self.country	= country
		self.currency	= currency
		id = nil
	}
}



/*
 
 EXAMPLE:
 
 "id": "checkout_848581559f4ea6980684b1d3ab30512f",
 "status": "NEW",
 "language": null,
 "merchant_color": null,
 "merchant_logo": null,
 "merchant_website": "https://www.rapyd.net",
 "merchant_customer_support": {},
 "merchant_alias": "N/A",
 "merchant_terms": null,
 "merchant_privacy_policy": null,
 "page_expiration": 1668221576,
 "redirect_url": "https://sandboxcheckout.rapyd.net?token=checkout_848581559f4ea6980684b1d3ab30512f",
 "merchant_main_button": "place_your_order",
 "cancel_checkout_url": "https://www.rapyd.net",
 "complete_checkout_url": "https://www.rapyd.net",
 "country": "US",
 "currency": "USD",
 "amount": 100,
 "payment": {
 "id": null,
 "amount": 100,
 "original_amount": 0,
 "is_partial": false,
 "currency_code": "USD",
 "country_code": "US",
 "status": null,
 "description": "Payment via Checkout",
 "merchant_reference_id": null,
 "customer_token": null,
 "payment_method": null,
 "payment_method_data": {},
 "expiration": 0,
 "captured": false,
 "refunded": false,
 "refunded_amount": 0,
 "receipt_email": null,
 "redirect_url": null,
 "complete_payment_url": null,
 "error_payment_url": null,
 "receipt_number": null,
 "flow_type": null,
 "address": null,
 "statement_descriptor": null,
 "transaction_id": null,
 "created_at": 0,
 "updated_at": 0,
 "metadata": null,
 "failure_code": null,
 "failure_message": null,
 "paid": false,
 "paid_at": 0,
 "dispute": null,
 "refunds": null,
 "order": null,
 "outcome": null,
 "visual_codes": {},
 "textual_codes": {},
 "instructions": {},
 "ewallet_id": null,
 "ewallets": [],
 "payment_method_options": {},
 "payment_method_type": null,
 "payment_method_type_category": null,
 "fx_rate": null,
 "merchant_requested_currency": null,
 "merchant_requested_amount": null,
 "fixed_side": null,
 "payment_fees": null,
 "invoice": null,
 "escrow": null,
 "group_payment": null,
 "cancel_reason": null,
 "initiation_type": "customer_present",
 "mid": null,
 "next_action": "not_applicable"
 },
 "payment_method_type": null,
 "payment_method_type_categories": null,
 "payment_method_types_include": null,
 "payment_method_types_exclude": null,
 "customer": null,
 "custom_elements": {
 "save_card_default": false,
 "display_description": false,
 "payment_fees_display": true,
 "merchant_currency_only": false,
 "billing_address_collect": false,
 "dynamic_currency_conversion": false
 },
 "timestamp": 1667011976,
 "payment_expiration": null,
 "cart_items": [],
 "escrow": null,
 "escrow_release_days": null
 */
