//
//  GitaRequestManager.swift
//  Gita
//
//  Created by Olga Zhegulo on 16/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//
//	Server documentation:
//		http://gita.dev.ironwaterstudio.com/help/api/
//


final class GitaRequestManager: RequestManager {
	
	static let kHostUrl: String = "http://app.bhagavadgitaapp.online"
//	static let kHostUrl: String = "http://gita.dev.ironwaterstudio.com"
	static let kServerUrl: String = kHostUrl + "/api/"
	
	typealias RequestErrorBlock = (RequestError) -> Void
	
	override func supportedResponseCodes() -> Set<Int> {
		return Set<Int>([
			200,
			201,
			401,
			500
			])
	}
	
	override func expectedMimeTypes() -> Set<String> {
		return Set<String>([
			"application/json",
			"text/x-json",
			"text/html",
			// Downloading files
			"application/octet-stream",
			"audio/mpeg"
			])
	}

	override func processReceivedData(_ responseObj: Any, with state: RequestManagerState) -> Any {
		guard let jsonDataDic = responseObj as? NSDictionary else { return responseObj }

		let code = jsonDataDic["code"] as? Int
		let data = jsonDataDic["data"]
		let message = jsonDataDic["message"] as? String

		if code ?? 0 == 0, let data = data {
			return data
		}

		let error = RequestError()
		error.isSuccess = false
		error.data = data
		error.msg = message
		error.code = code ?? 0
				
		return error
	}
	
	private static func runRequest(requestMethodUrl: String,
	                               params: Any,
	                               contextKey: AnyHashable?,
	                               successBlock: @escaping RequestSuccessBlock,
	                               errorBlock: @escaping RequestErrorBlock) -> Self? {
		let dic: NSDictionary = params as! NSDictionary
		
		let requestParams: NSDictionary? = dic["params"] as? NSDictionary
		let urlString = kServerUrl + requestMethodUrl

		return self.performRequest(
			path: urlString as String,
			method: "POST",
			headers: nil,
			parameters: requestParams,
			contextKey: contextKey,
			success: successBlock,
			progress: nil,
			error: errorBlock)
	}
	
	// MARK: Data
	@discardableResult
	static func getLanguages(context: AnyHashable? = nil, success: @escaping ([Language]) -> Void, error: @escaping RequestErrorBlock) -> Self? {
		return self.runRequest(requestMethodUrl: "Data/Languages",
		                       params: [:],
		                       contextKey: context,
		                       successBlock: { (data) in
								var items = [Language]()
								if let tempItems = try? Language.getFromDataArray(data as? [[String: Any]]) {
									items = tempItems ?? [Language]()
								}
								success(items)
		},
		                       errorBlock: { (err) in
								error(err)
		})
	}
	
	@discardableResult
	static func getBooks(ids: [Int] = [], context: AnyHashable? = nil, success: @escaping ([Book]) -> Void, error: @escaping RequestErrorBlock) -> Self? {
		return self.runRequest(requestMethodUrl: "Data/Books",
		                       params: ["params": ["ids" : ids]],
		                       contextKey: context,
		                       successBlock: { (data) in
								var items = [Book]()
								if let tempItems = try? Book.getFromDataArray(data as? [[String: Any]]) {
									items = tempItems ?? [Book]()
								}
								success(items)
		},
		                       errorBlock: { (err) in
								error(err)
		})
	}

	@discardableResult
	static func getChapters(bookId: Int, context: AnyHashable? = nil, success: @escaping ([Chapter]) -> Void, error: @escaping RequestErrorBlock) -> Self? {
		return self.runRequest(requestMethodUrl: "Data/Chapters",
		                       params: ["params": ["bookId" : bookId]],
		                    contextKey: context,
		                    successBlock: { (data) in
								var items = [Chapter]()
								if let tempItems = try? Chapter.getFromDataArray(data as? [[String: Any]]) {
									items = tempItems ?? [Chapter]()
								}
								
								//Fill required field, that does not come from server
								for itm in items {
									itm.bookId = bookId
								}
								success(items)
							},
		                    errorBlock: { (err) in
								error(err)
							})
	}
	
	@discardableResult
	static func getQuote(context: AnyHashable? = nil, success: @escaping (Quote?) -> Void, error: @escaping RequestErrorBlock) -> Self? {
		return self.runRequest(requestMethodUrl: "Data/Quotes",
							   params: [:],
							   contextKey: context,
							   successBlock: { (data) in
								let item: Quote? = (try? Quote.getFromDictionary(data as? [String : Any])) ?? nil
								success(item)
		},
							   errorBlock: { (err) in
								error(err)
		})
	}
}
