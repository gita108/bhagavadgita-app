//
//  RequestManager.swift
//  RequestManager
//
//  Created by Stanislav Grinberg on 17 Apr 2018.
//	Updated by Stanislav Grinberg on 01 Jun 2018.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//
//  Changes history:
//		04 Apr 2018. Stanislav Grinberg:
//			* Supported asterisk suffix for contextKey in cancelAllConnections method.
//		1 Jun 2018. Stanislav Grinberg:
//			* Fixed bug with cancelAllConnections(context:) method, when used context with asterisk suffix.
//

import Foundation

//TODO: need to add CANCEL functionality to the ReqMan while perfoming command/transferring or receiving data

@objc
protocol RequestErrorDelegate: NSObjectProtocol {
	typealias LoginSuccessBlock = ([String: Any]) -> ()
	typealias LoginErrorBlock = (RequestError) -> ()
	typealias ConnectionRestoringBlock = (Bool) -> ()
	
	// Method that should be call to process error:
	//	- when error type is NeedToRelogin, then need restore login session & call LoginSuccessBlock
	//  - when error type is not NeedToRelogin, then procession of error will be terminated on end point (code that performs request)
	func requestError(_ error: RequestError, didHandled successBlock: LoginSuccessBlock, didSkipped errorBlock: LoginErrorBlock)
	
	// Optional
	@objc optional func requestError(_ error: RequestError, didUserDataUpdated userData: [String: Any])
	// When this method is implemented, we can configure to manually process all error types except relogin error, otherwise connection errors will be processed automatically
	// By default errors is autohandled. We should implemnt this method when server support logic to restoring login state.
	@objc optional func requestErrorWillAutoHandled(_ error: RequestError) -> Bool
	// This method can be optional, because when requestErrorWillAutoHandled is not implemented
	//  all connection errors will be processed in NetworkErrorManager (i.e. we should process only login errors in requestError:didHandled:didSkipped:)
	@objc optional func requestError(_ error: RequestError, didConnectionLost connectionBlock: ConnectionRestoringBlock)
}

/// RequestManager has possibility to perform blocks in specified queue.
/// - Note: To achieve this goal we should setup RequestManager.sharedConfiguration.queue and specify here DispatchQueue.global(), otherwise - will be used main queue (DispatchQueue.main). But all requests processing logic ALWAYS will be performed in RequestManager 'internal queue'!
/// - Warning: When you not needed use depended queries and long time post processing (after processRecieveData) then you should not configure queue parameter.
/// - Remark: When you need cofigure `queue` configuration param,
/// this example shows a `queue` configuration param that performs all blocks in global queue:
///
/// - `RequestManager.sharedConfiguration.queue = DispatchQueue.global()`
///
/// or performing individual request in global queue:
///
/// - `<Custom>RequestManager.runRequest(..., configuration: RequestManager.sharedConfiguration.copy().queue(DispatchQueue.global(), ...))`
class RequestManager: BaseRequestManager, BaseRequestManagerDelegate {
	
	static var sharedConfiguration: RequestManagerConfiguration = RequestManagerConfiguration()
	
	private static var sharedContext = Dictionary<AnyHashable, ContiguousArray<RequestManager>>()
	
	final let contextKey: AnyHashable
	final private(set) weak var errorDelegate: RequestErrorDelegate?
	
	private var configuration: RequestManagerConfiguration
	private var retriesCount: Int
	
	//private var lastError: RequestError?
	
	// MARK: - Initialization
	
	private override init() { fatalError() }
	
	required init(errorDelegate: RequestErrorDelegate?, contextKey: AnyHashable, configuration: RequestManagerConfiguration) {
		self.errorDelegate = errorDelegate
		self.contextKey = contextKey
		self.configuration = configuration
		self.retriesCount = 0
		super.init()
	}
	
	// MARK: - Virtual/Overridable methods
	
	override func supportedResponseCodes() -> Set<Int> {
		/*
		400 // Bad request
		401 // Not autorized
		404 // Not found
		408 // Request timeout
		413 // Request entity too large
		414 // Request URI too large
		*/
		return [
			200,	// Get ok
			201,	// Post ok
		]
	}
	
	override func needToReloginResponseCodes() -> Set<Int> {
		return [
			401  // Not autorized
		]
	}
	
	override func expectedMimeTypes() -> Set<String> {
		return [
			"application/json",
			"text/x-json",
			"text/html",
			// Downloading files
			"application/octet-stream",
			// Images
			"image/jpg",
			"image/jpeg",
			"image/pjpeg",
			"image/png",
			"image/gif",
			"image/webp"
		]
	}
	
	override func processReceivedData(_ responseObj: Any, with state: RequestManagerState) -> Any {
		return responseObj
	}
	
	func proccess(errorState err: RequestError) -> RequestError {
		if let httpResponse = err.response as? HTTPURLResponse {
			
			if OperationResultCode(rawValue: err.code) == .needToLogin || needToReloginResponseCodes().contains(httpResponse.statusCode) {
				err.needToRelogin = true
				// Mark error is handled to prevent retry-sending same requests
				err.isHandled = true
			}
			
			// Stop processing errors when statusCode = 500
			if httpResponse.statusCode == 500 || httpResponse.statusCode == 404 {
				err.isConnectionError = true
				// Mark error is handled to prevent retry-sending same requests
				err.isHandled = true
			}
		}
		
		return err
	}
	
	// MARK: - Static methods

	static func performRequest(path: String,
	                           method: String,
	                           headers: [String: String]? = nil,
	                           parameters: Any?,
	                           configuration: RequestManagerConfiguration = sharedConfiguration,
	                           errorDelegate: RequestErrorDelegate? = nil,
	                           contextKey: AnyHashable? = nil,
	                           success: RequestSuccessBlock?,
	                           progress: RequestProgressBlock? = nil,
	                           error: RequestErrorBlock?) -> Self {
		
		let _contextKey: AnyHashable
		if contextKey == nil {
			_contextKey = String(describing: self)
		} else {
			_contextKey = contextKey!
		}
		
		let reqMan = self.init(errorDelegate: errorDelegate, contextKey: _contextKey, configuration: configuration)
		// Add request manager to context only after ensuring that it was successfully prepared for work
		add(requestManager:reqMan, toContext: reqMan.contextKey)
		
		// COOKIES: old (not used)
		let cookies: [HTTPCookie]? = nil//self.getAvailableCookies(requestPath)
		
		reqMan.runRequest(path: path,
		                  headers: headers,
		                  parameters: parameters,
		                  method: method,
		                  cookies: cookies,
		                  autoStart: reqMan.configuration.autoStart,
		                  sequential: reqMan.configuration.isSequential,
		                  timeoutInterval: reqMan.configuration.timeoutInterval,
		                  callbacksQueue: reqMan.configuration.queue,
		                  success: { [unowned reqMan] (dataObj: Any) in
							success?(dataObj)
							
							type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
			              },
		                  progress: progress,
		                  error: { [unowned reqMan] (err: RequestError) in
							//err.innerError = reqMan.lastError
							//reqMan.lastError = err
							
							let handledError: RequestError = reqMan.proccess(errorState: err)
							
							// If we need to interrupt of processing error
							if handledError.stopProcessing {
								type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
								return
							}
							
							// We skip manually processing in several situations:
							// 1. error has handled
							// 2. error isn't related to connection error or need to relogin
							// 3. we've performed maximum allowed retries count
							if handledError.isHandled ||
								(!handledError.isConnectionError && !handledError.needToRelogin) ||
								reqMan.retriesCount == reqMan.configuration.retriesCount
							{
								error?(handledError)
								type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
								return
							}
							
							// We try to perform the same request if current number of retries is less than max allowed
							let performNewRequestBlock = { [weak reqMan] in
								guard let reqMan = reqMan else { return }
								
								reqMan.retriesCount += 1
								
								// Try restart reqMan
								reqMan.retryRequest()
							}
							
							// Вызов error блока с возможностью повторной обработки отсутсвия интернет соединения
							let retryErrorBlock = {
								// Try handle error manually when offline mode supported and when isHandled is not set continue processing with NetworkErrorManager
								if reqMan.configuration.offlineModeSupport {
									error?(handledError)
									
									if handledError.isHandled {
										type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
										return
									}
								}
								
								handledError.isHandled = true
								NetworkErrorManager.shared.add(reqMan,
								                               requestError: handledError,
								                               success: { performNewRequestBlock() },
								                               cancel: {
																error?(handledError)
																
																// When ReqMan instance is present in contextKey dictionary, then we can perform cancelling request by call errorBlock
																type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
								})
							}
							
							// Start process of handling connection error or needToRelogin
							
							// If custom "error delegate is specified & error type is not needToRelogin"
							// then check requestErrorWillAutoHandled: result or use YES as result
							var shouldDelegateHandleError = false
							if reqMan.errorDelegate != nil {
								if reqMan.errorDelegate!.responds(to: #selector(RequestErrorDelegate.requestErrorWillAutoHandled(_:))) {
									shouldDelegateHandleError = !(reqMan.errorDelegate!.requestErrorWillAutoHandled!(handledError))
								} else {
									shouldDelegateHandleError = true
								}
							}
							
							// TODO: Возможно нужно будет вызывать методы делегата на определенном потоке
							
							if shouldDelegateHandleError {
								let errorDelegate = reqMan.errorDelegate!
								
								// Handle needToRelogin
								if handledError.needToRelogin {
									// TODO: В дальнейшем если будет работать делегат, то надо разобраться с блоками, т.к там есть захваты errorDelegate, reqMan
									errorDelegate.requestError(handledError,
									                           didHandled: { (userData: [String : Any]) in
																handledError.isHandled = true
																// TODO: THIS stopProcessing = YES ADDED ONLY IN SLETAT PROJECT - interrupt processing this error
																handledError.stopProcessing = true
																//Re-saving user credentials
																
																errorDelegate.requestError?(handledError, didUserDataUpdated: userData)
																
																performNewRequestBlock()
									                           },
									                           didSkipped: { (err: RequestError) in
																// TODO: Может лучше так написать
																// guard !err.stopProcessing else { return }
																// и сверху коммент добавить
																if !err.stopProcessing {
																	error?(handledError)
																	type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
																} else {
																	//Do nothing, need to release this instance of reqMan (i.e. for the cases when need to show login screen and continue app live cycle from the scratch)
																}
									})
									
									return
								}
								
								// Handle connection error
								
								// If custom error delegate implements requestError:didConnectionLost: method then give processing to it
								if (errorDelegate.responds(to: #selector(RequestErrorDelegate.requestError(_:didConnectionLost:)))) {
									// TODO: В дальнейшем если будет работать делегат, то надо разобраться с блоками, т.к там есть захваты errorDelegate, reqMan
									errorDelegate.requestError!(handledError,
									                            didConnectionLost: { (needToRestore: Bool) in
																	handledError.isHandled = true
																	if needToRestore {
																		// TODO: THIS stopProcessing = true ADDED ONLY IN SLETAT PROJECT - interrupt processing this error
																		handledError.stopProcessing = true
																		performNewRequestBlock()
																	} else {
																		//TODO: allowing skip re-sending request when navigation from current tab and when need to handle error in block
																		error?(handledError)
																		type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
																	}
									})
									
									return
								}
								
								// If cutom error delegate can't handle connection error
								
								// If custom error delegate doesn't implement requestError:didConnectionLost: method then call standard centralized processing
								retryErrorBlock()
								
								return
							}
							
							// If custom "error delegate is not specified and it isn't connection related error (i.e. needToRelogin)
							// WARNING: We do not handle needToRelogin error because Login case should be handled from main code
							if handledError.needToRelogin {
								error?(handledError)
								type(of: reqMan).remove(requestManager: reqMan, fromContext: reqMan.contextKey)
							} else {
								// If custom "error delegate is not specified and it is connection related error
								retryErrorBlock()
							}
		})
		
		// Add request manager to context only after ensuring that it was successfully prepared for work
		//add(requestManager:reqMan, toContext: reqMan.contextKey)
		
		return reqMan
	}
	
	// MARK: Cookie processing methods
	
	static func clearSavedCookies(_ requestPath: String) {
		let requestUrl = URL(string: requestPath)!
		//		let stringUrl = "\(requestUrl.scheme)://\(requestUrl.host)"
		//		// Cookie
		//		let url = URL(string: stringUrl)!
		
		let storage = HTTPCookieStorage.shared
		if let cookies = storage.cookies(for: requestUrl) {
			for each in cookies {
				storage .deleteCookie(each)
			}
		}
		
		// COOKIES: old (not used)
		//		UserDefaults.standard.removeObject(forKey: stringUrl)
	}
	
	// COOKIES: old (not used)
	//	/// Returns array of NSHTTPCookie objects
	//	func getAvailableCookies(_ stringUrl: String) -> [HTTPCookie] {
	//		guard let requestPath = self.requestPath else { return [] }
	//
	//		let requestUrl = URL(string: requestPath)!
	//		let stringUrl = "\(requestUrl.scheme!)://\(requestUrl.host!)"
	//
	//		let url = URL(string: stringUrl)!
	//
	//		var availableCookies = [HTTPCookie]()
	//		let cookies = HTTPCookieStorage.shared.cookies(for: url)
	//		if let cookies = cookies, cookies.count > 0 {
	//			availableCookies.append(contentsOf: cookies)
	//		} else {
	//			if let cookieDictionary = UserDefaults.standard.dictionary(forKey: stringUrl) {
	//				for (cookieName, cookieProperties) in cookieDictionary {
	//					if let cookie = HTTPCookie(properties: cookieProperties as! [HTTPCookiePropertyKey : Any]) {
	//						availableCookies.append(cookie)
	//					}
	//				}
	//				// TODO: mb need save availableCookies here?!
	//				HTTPCookieStorage.shared.setCookies(availableCookies, for: url, mainDocumentURL: nil)
	//			}
	//		}
	//
	//		return availableCookies
	//	}
	//
	//	private func mergeCookies(newCookies: [HTTPCookie], oldCookies: [HTTPCookie]) -> [HTTPCookie] {
	//		/*
	//		let firstCookie: HTTPCookie = receivedCookies.first!
	//		firstCookie.name
	//
	//		let setCookie = httpResponse.allHeaderField["Set-Cookie"]
	//		print("Set cookie = \(setCookie)")
	//
	//		//Example of complex cookie:
	//		//		ASP.NET_SessionId=0i5rjfka5qr4fxbk1g0xk3ni; path=/; HttpOnly, .ASPXFORMSAUTH=7E11B10FBEBCA700D6994604C5E0DDC35D7A6DC7FDC8E1C384E0ED14032DAD5460332A48F2469BB31B177B39282E22033613DF300E3140E4EB56038500FEFD38409C064F0B31955BCA40463C22DC2E86DD2A5F59D7007434428BB1B7C154E9C21ADE6FA90AD5139E3AFC259C6D930AF9551533BA295053A643E4A1403D2CA0C8; path=/
	//		//
	//		//		Here we can see two cookies: "ASP.NET_SessionId" & ".ASPXFORMSAUTH" that is comma-separated
	//		//		All values in each cookie semicolon separated
	//		//
	//		//		ASP.NET_SessionId=0i5rjfka5qr4fxbk1g0xk3ni; path=/; HttpOnly
	//		//		.ASPXFORMSAUTH=7E11B10FBEBCA700D6994604C5E0DDC35D7A6DC7FDC8E1C384E0ED14032DAD5460332A48F2469BB31B177B39282E22033613DF300E3140E4EB56038500FEFD38409C064F0B31955BCA40463C22DC2E86DD2A5F59D7007434428BB1B7C154E9C21ADE6FA90AD5139E3AFC259C6D930AF9551533BA295053A643E4A1403D2CA0C8; path=/
	//
	//		//To access received newly created cookies we can use following code
	//		let cookie = httpResponse.allHeaderField["Cookie"]
	//
	//		//To manually create cookies and fill headers with it we should perform following code
	//		let dic = ["Set-Cookie": "name=value; path=/; domain=.test.com;, name2=value2; path=/;"]
	//		let cookies = HTTPCookie.cookies(withResponseHeaderFields: dic, for: URL(string: "http://www.foo.com/"))
	//		*/
	//
	//		var mergedCookies = newCookies
	//		// Cookie merging
	//		for oldCookie in oldCookies {
	//			// Checking that oldCookies is not present in newCookies
	//			var sameCookie: HTTPCookie?
	//			for newCookie in newCookies {
	//				if oldCookie.name == newCookie.name {
	//					sameCookie = newCookie
	//					break
	//				}
	//			}
	//			// If the same cookie then we can merge properties
	//			if sameCookie != nil {
	//				//Nothing
	//			}
	//			//If new cookie then need to add cookie
	//			else {
	//				mergedCookies.append(oldCookie)
	//			}
	//		}
	//
	//		return mergedCookies
	//	}
	//
	//	private func saveCookies(_ cookies: [HTTPCookie], fromUrl requestPath: String) {
	//		let requestUrl = URL(string: requestPath)!
	//		let stringUrl = "\(requestUrl.scheme!)://\(requestUrl.host!)"
	//
	//		let url = URL(string: stringUrl)
	//
	//		// Merge cookies
	//		let mergedCookies = mergeCookies(newCookies: cookies, oldCookies: getAvailableCookies(requestPath))
	//		// Save cookies in cookie storage
	//		HTTPCookieStorage.shared.setCookies(mergedCookies, for: url, mainDocumentURL: nil)
	//		// Save cookies in user defaults
	//		var cookieDictionary: [String: Any] = [:]
	//		for cookie in mergedCookies {
	//			cookieDictionary[cookie.name] = cookie.properties
	//		}
	//
	//		UserDefaults.standard.set(cookieDictionary, forKey: stringUrl)
	//	}
	
	// COOKIES: old (not used)
	//	func requestManager(_ requestManager: BaseRequestManager, didCookieRecieved cookies: [HTTPCookie], url: String) {
	//		saveCookies(cookies, fromUrl: url)
	//	}
	
	//func requestManager(_ requestManager: BaseRequestManager, didFinishWithData responseObj: Any) {}
	//func requestManager(_ requestManager: BaseRequestManager, didFailWith response: URLResponse) {}
	
	// MARK: - Connection management
	
	/**
		Cancel current performed connection.
 		@warning This method is used to terminate connection while performing request. When this method is called, success & error blocks is not fired.
 		@code
 		RequestManager *reqMan;
		some initialization
 		[reqMan cancelConnection];
 		@endcode
 		@return None.
 	*/
	 override func cancelConnection() {
		//Remove from context when reqMan no longer needed
		type(of: self).remove(requestManager: self, fromContext: contextKey)
		
		NetworkErrorManager.shared.remove(self)

		super.cancelConnection()
	}
	
	// MARK: - Context functionality

	private static var locker = Locker()
	
	/// Impossible to use asterisks ('\*' character) in key and AllContextsKey constant.
	private static func add(requestManager reqMan: RequestManager, toContext contextKey: AnyHashable? = nil) {
		locker.lock() {
			let _contextKey: AnyHashable
			if contextKey == nil {
				_contextKey = String(describing: type(of: reqMan))
			} else {
				_contextKey = contextKey!
			}
			
			if _contextKey == allContextsKey {
				fatalError("*** RequestManager fatal error: impossible to use allContextsKey exactly/directly!")
			} else if let key = _contextKey as? String, key.contains("*") {
				fatalError("*** RequestManager fatal error: impossible to use asterisk character in key expression!")
			}
			
			var contextItemsByKey = sharedContext[_contextKey]
			
			if contextItemsByKey != nil {
				if !contextItemsByKey!.contains(reqMan) {
					contextItemsByKey!.append(reqMan)
				}
			} else {
				contextItemsByKey = ContiguousArray([reqMan])
			}
			
			sharedContext[_contextKey] = contextItemsByKey
		}
	}
	
	static func remove(requestManager reqMan: RequestManager, fromContext contextKey: AnyHashable? = nil) {
		locker.lock() {
			let _contextKey: AnyHashable
			if contextKey == nil {
				_contextKey = String(describing: type(of: reqMan))
			} else {
				_contextKey = contextKey!
			}
			
			if var contextItemsByKey = sharedContext[_contextKey] {
				for i in 0..<contextItemsByKey.count {
					if contextItemsByKey[i] === reqMan {
						contextItemsByKey.remove(at: i)
						break
					}
				}
				
				if contextItemsByKey.count == 0 {
					sharedContext[_contextKey] = nil
				} else {
					sharedContext[_contextKey] = contextItemsByKey
				}
			}
		}
	}
	
	/// This constant can be used tyo cancel all contexts connections.
	/// It's provided to solve cases when context key can be present as String or as AnyHashable object.
	/// But when used only String keys then as alternative can be used asterisks string, i.e. "\*".
	static let allContextsKey: AnyHashable = NSObject()
	/**
		Cancels all performed requests by contextKey.
	@param contextKey Context key or empty string to cancel all context requests. Supported asterisk suffix ('\*' character), i.e. 'SomeContext', 'SomeContextData', 'SomeContextMore' will be removed when specified 'SomeContext\*'. But contextKey can't contains only asterisk, i.e. impossible contextKey != "*".
		@warning If @b contextKey param is nil then this method nothing will be do.
		@code
		 [RequestManager cancelConnection];
		@endcode
 	*/
	static func cancelAllConnections(_ contextKey: AnyHashable? = nil) {
		locker.lock() {
			let _contextKey: AnyHashable
			if contextKey == nil {
				_contextKey = String(describing: self)
			} else {
				_contextKey = contextKey!
			}
			
			// When exactly specified contextKey with constant value *allContextsKey* that means: cancel all connections from all contexts.
			if _contextKey == allContextsKey {
				for key in sharedContext.keys {
					innerCancelAllConnections(key)
				}
			} else if let key = _contextKey as? String, key.hasSuffix("*")/*, key.count > 1*/ { // Checking ending with asterisk ('*' character).
				#if swift(>=4.0)
					let searchKey = String(key[key.startIndex..<key.index(before: key.endIndex)])
				#else
					let searchKey = String(key[key.startIndex..<key.index(before: key.endIndex)])!
				#endif
				for sharedKey in sharedContext.keys {
					if let itemKey = sharedKey as? String, itemKey.hasPrefix(searchKey) {
						innerCancelAllConnections(itemKey)
					}
				}
			} else { // Removing by specifying key exactly.
				innerCancelAllConnections(_contextKey)
			}
		}
	}
	
	/**
		Intenal method to removing all context connections by specifying contextKey exactly, i.e. without asterisk ('\*' character).
	*/
	private static func innerCancelAllConnections(_ contextKey: AnyHashable) {
		if let contextItemsByKey = sharedContext[contextKey] {
			for reqMan in contextItemsByKey {
				//NetworkErrorManager.shared.remove(reqMan)
				//BaseRequestManager.cancelConnection(reqMan)()
				reqMan.cancelConnection()
			}
			
			sharedContext[contextKey] = nil
		}
	}
}
