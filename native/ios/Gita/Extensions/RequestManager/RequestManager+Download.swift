//
//  RequestManager+Download.swift
//  RequestManager
//
//  Created by Stanislav Grinberg on 08/09/2017.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

extension RequestManager {
	
	enum CacheType {
		case none // Без кеширования
		case `static` // Данные всегда тянутся с кэша, пока не истек период
		case dynamic // Данные тянет из кеша, но делается заврос к серверу с датой
		case offline // При отсутствии инета, данные подтянутся из кеша
		case smart // Два раза вызывается блок success, первый из кеша, второй с сервера
	}
	
	typealias CachedRequestSuccessBlock = (Any, Bool) -> ()
	typealias DownloadImageSuccessBlock = (UIImage?) -> ()
	
	private static let fileQueue = DispatchQueue(label: "DownloadExtensionFileQueue")
	
	// 1) absoluteUrl, 2) cachePath, 3) writeToFile
	//
	// * 1) ... 2) ... 3) ... => fileName = ... , filePath = <CACHE_PATH>|<LOCAL_PATH>/... (fileName)
	//
	// * host: www.tomato-pizza2.u-sl.ru, relativePath: /image/uploaded/146833193630151.png, query: a=b&1=2
	//
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/146833193630151.png?a=b&1=2" 2) cachePath = "Avatars/150/avatar_50.png" 3) writeToFile = "/Files/"
	//	=> fileName = "avatar_50.png", filePath = "Avatars/150/avatar_50.png"
	//
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/146833193630151.png?a=b&1=2" 2) cachePath = <"Avatars/150/">|<"/"> 3) writeToFile = "/Files/"
	//	=> fileName = "146833193630151.png", filePath = "Avatars/150/146833193630151.png"
	// *
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/146833193630151.png?a=b&1=2" 2) cachePath = <"">|<nil> 3) writeToFile = "/Files/"
	//	=> fileName = "146833193630151.png", filePath = "ApplicationDirectory/Documents/Files/146833193630151.png"
	// *
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/146833193630151.png?a=b&1=2" 2) cachePath = "Avatars/150/avatar_50.png" 3) writeToFile = nil
	//	=> fileName = "avatar_50.png", filePath = "Avatars/150/avatar_50.png"
	// *
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/" 2) cachePath = <"Avatars/150/">|<"/"> 3) writeToFile = nil
	//	=> fileName = "<HASH>("www.tomato-pizza2.u-sl.ru")_<HASH>("/image/uploaded/146833193630151.png")_<HASH>("a=b&1=2")", filePath = "Avatars/150/<HASH>("www.tomato-pizza2.u-sl.ru")_<HASH>("/image/uploaded/146833193630151.png")_<HASH>("a=b&1=2")"
	// *
	// * 1) absoluteUrl = @"http://www.tomato-pizza2.u-sl.ru/image/uploaded/146833193630151.png?a=b&1=2" 2) cachePath = <"">|<nil> 3) writeToFile = nil
	//	=> fileName = nil	, filePath = nil
	// *
	
	/**
	When cachePath is specified then he will have priority vs path (when cachePath is not contains fileName then it will be extracted from absoluteUrl, otherwise - generated)
	When cachePath is empty and path is specified then it be used (when path is not contains fileName then it will be extracted from absoluteUrl, otherwise - generated)
	When both cachePath and path is empty then data will not be cached and stored in file
	@Note If we have cachePath we will not write to file!
	@Note If cachePath or path will be specified like "/some" or "some" directory will not be created and file "some" may be overwritten.
	*/
	
	@discardableResult
	static func download(absoluteUrl: String,
	                     method: String,
	                     headerParams: [String: String]? = nil,
	                     parameters: Any?,
	                     configuration: RequestManagerConfiguration = sharedConfiguration,
	                     contextKey: AnyHashable? = nil,
	                     cacheType: CacheType,
	                     cachePath: String? = nil, //relative to cahceDir path
	                     path: String? = nil, // relative to docs dir path
	                     success: CachedRequestSuccessBlock?,
	                     progress: RequestProgressBlock? = nil,
	                     error: RequestErrorBlock?) -> Self? {
		
		if self == RequestManager.self {
			NSException(
				name: .internalInconsistencyException,
				reason: "Need to call this method from local RequestManager (<ProjectName>RequestManager)",
				userInfo: nil).raise()
		}
		
		if configuration.isSequential && cacheType != .none {
			print("WARNING: When specified file path and caching mode then two files will be created in cache and documents directories!\nUsing path param assume that data can have big size and caching + process object in memory is not expected.")
			NSException(
				name: .internalInconsistencyException,
				reason: "When specified file path and caching mode then two files will be created in cache and documents directories!\nUsing path param assume that data can have big size and caching + process object in memory is not expected.",
				userInfo: nil).raise()
		}
		
		let initialRetriesCount = configuration.retriesCount

		let localConfig = RequestManagerConfiguration(configuration: configuration)
		localConfig.autoStart = true
		localConfig.retriesCount = 0
		localConfig.isSequential = path != nil && !path!.isEmpty
		//localConfig.queue = (localConfig.isSequential || cacheType != .none) ? fileQueue : nil
		if localConfig.isSequential || cacheType != .none {
			localConfig.queue = fileQueue
		}
		

		/* TODO: replace with short syntax
		let localConfig = configuration.copy().autoStart(true).retriesCount(0).isSequential(path != nil && !path!.isEmpty)
		localConfig.queue = (localConfig.isSequential || cacheType != .none) ? fileQueue : nil
		*/
		
		// Build file path
		var filePath: String?
		if cacheType != .none {
			filePath = relativePath(for: absoluteUrl, path: cachePath, headers: headerParams, parameters: parameters)
		} else if let path = path, !path.isEmpty {
			filePath = relativePath(for: absoluteUrl, path: path, headers: headerParams, parameters: parameters)
		}
		
		let cacheMan: CacheManager? = cacheType != .none ? CacheManager.globalCache : nil
		
		let successWithCacheData = {
			if let cachedObject = cacheMan?.object(forPath: filePath!) {
				success?(cachedObject, true)
			}
		}
		
		// If we already have cached file then return it
		if (cacheType == .`static` || cacheType == .smart) && cacheMan!.hasCache(forPath: filePath) {
			successWithCacheData()
			
			if cacheType == .`static` {
				return nil
			}
		}
		
		// Create file if needed and open it for writing only when writeToFile = true
		var file: FileHandle?
		if localConfig.isSequential {
			performOnQueue(fileQueue) { file = self.fileHandle(for: filePath!) }
		}
		
		// Update headers
		var headers: [String: String] = headerParams ?? [:]
		if cacheType == .dynamic, cacheMan!.hasCache(forPath: filePath) {
			let cachedFileAttributes = try! FileManager.default.attributesOfItem(atPath: cacheMan!.buildAbsolutePath(relativePath: filePath))
			headers["If-Modified-Since"] = htmlDateString(for: cachedFileAttributes[FileAttributeKey.creationDate] as? Date)
		}
		
		var currentRetriesCount = 0
		
		// Для автоматического выведения типа, который будет равен Self
		var reqMan = self.init(errorDelegate: nil, contextKey: "", configuration: localConfig)
		reqMan = performRequest(path: absoluteUrl,
		                        method: method,
		                        headers: headers,
		                        parameters: parameters,
		                        configuration: localConfig,
		                        contextKey: contextKey,
		                        success: { (data: Any) in
									let isEmpty: Bool
									if let obj = data as? [String: Any] {
										isEmpty = obj.keys.count == 0
									} else if let obj = data as? Data {
										isEmpty = obj.count == 0
									} else {
										isEmpty = false
									}
									
									// When data is not modified then try to return from cache
									if isEmpty, cacheType == .dynamic, cacheMan!.hasCache(forPath: filePath) {
										print("not modified received")
										successWithCacheData()
										return
									}
									
									// Cache data when it needed
									if cacheType != .none {
										if let dataObj = data as? NSCoding {
											cacheMan!.setObject(dataObj, forPath: filePath!)
										} else {
											print("Given object does not conforms to NSCoding protocol and will not be cached!")
										}
									}
									
									// Return coresponding result
									if localConfig.isSequential {
										file?.closeFile()
										let absouluteFilePath: NSString = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
										success?(absouluteFilePath.appendingPathComponent(filePath!), false)
									} else {
										success?(data, false)
									}
									
								},
		                        progress: { (bytes: Int, totalBytes: Int, data: Data?) in
									if localConfig.isSequential {
										if let data = data, data.count > 0 {
											//print("write portion, bytes: \(bytes), totalBytes: \(totalBytes)")
											file?.write(data)
										}
									}
									
									progress?(bytes, totalBytes, data)
								},
		                        error: { (err: RequestError) in
									if cacheType == .smart, cacheMan!.hasCache(forPath: filePath) {
										return
									}
									
									if err.isConnectionError {
										let hasCachedData = cacheMan?.hasCache(forPath: filePath) ?? false
										
										if hasCachedData &&
										   (cacheType == .offline ||
										   (cacheType == .dynamic && currentRetriesCount == initialRetriesCount))
										{
											successWithCacheData()
										} else if currentRetriesCount < initialRetriesCount {
											currentRetriesCount += 1
											NetworkErrorManager.shared.add(reqMan,
											                               requestError: err,
											                               success: { reqMan.retryRequest() },
											                               cancel: { error?(err) })
										} else {
											error?(err)
										}
									} else {
										error?(err)
									}
								})
		
		return reqMan
	}

	// MARK: - Public method
	
	@discardableResult
	static func downloadData(absoluteUrl: String,
	                         method: String,
	                         headers: [String: String]?,
	                         parameters: AnyObject?,
	                         configuration: RequestManagerConfiguration = sharedConfiguration,
	                         contextKey: AnyHashable?,
	                         cacheType: CacheType,
	                         success: CachedRequestSuccessBlock?,
	                         progress: RequestProgressBlock?,
	                         error: RequestErrorBlock?) -> Self? {
		let configQueue: DispatchQueue? = configuration.queue
		
		return download(absoluteUrl: absoluteUrl,
		                method: method,
		                headerParams: headers,
		                parameters: parameters,
		                configuration: configuration,
		                contextKey: contextKey,
		                cacheType: cacheType,
		                cachePath: nil,
		                path: nil,
		                success: { (dataObj: Any, isFromCache: Bool) in
							performOnQueue(configQueue) { success?(dataObj, isFromCache) } },
		                progress: { (bytes: Int, totalBytes: Int, data: Data?) in
							performOnQueue(configQueue) { progress?(bytes, totalBytes, data) } },
		                error: { (err: RequestError) in
							performOnQueue(configQueue) { error?(err) } })
	}
	
	
	@discardableResult
	static func downloadFile(fileUrl: String,
	                         method: String,
	                         headers: [String: String]? = nil,
	                         configuration: RequestManagerConfiguration = sharedConfiguration,
	                         contextKey: AnyHashable?,
	                         cacheType: CacheType,
	                         cachePath: String?,
	                         path: String?,
	                         success: RequestSuccessBlock?,
	                         progress: RequestProgressBlock?,
	                         error: RequestErrorBlock?) -> Self? {
		let configQueue: DispatchQueue? = configuration.queue
		
		return download(absoluteUrl: fileUrl,
		                method: method,
		                headerParams: headers,
		                parameters: nil,
		                configuration: configuration,
		                contextKey: contextKey,
		                cacheType: cacheType,
		                cachePath: cachePath,
		                path: path,
		                success: { (dataObj: Any, isFromCache: Bool) in
							performOnQueue(configQueue) { success?(dataObj) } },
		                progress: { (bytes: Int, totalBytes: Int, data: Data?) in
							performOnQueue(configQueue) { progress?(bytes, totalBytes, data) } },
		                error: { (err: RequestError) in
							performOnQueue(configQueue) { error?(err) } })
	}
	
	@discardableResult
	static func downloadImage(imageUrl: String,
	                          method: String,
	                          parameters: [String: String]? = nil,
	                          configuration: RequestManagerConfiguration = sharedConfiguration,
	                          contextKey: AnyHashable?,
	                          cacheType: CacheType,
	                          cachePath: String?,
	                          path: String?,
	                          success: DownloadImageSuccessBlock?,
	                          progress: RequestProgressBlock? = nil,
	                          error: RequestErrorBlock?) -> Self? {
		let configQueue: DispatchQueue? = configuration.queue
		
		return download(absoluteUrl: imageUrl,
		                method: method,
		                headerParams: nil,
		                parameters: parameters,
		                configuration: configuration,
		                contextKey: contextKey,
		                cacheType: cacheType,
		                cachePath: cachePath,
		                path: path,
		                success: { (dataObj: Any, isFromCache: Bool) in
							var imageData: Data?
							// Если пришла строка то картинка находится в файловой системе
							if isFromCache, let path = dataObj as? String, let url = URL(string: path) {
								imageData = try! Data(contentsOf: url)
							} else if let data = dataObj as? Data {
								imageData = data
							}
							
							var image: UIImage?
							if let imageData = imageData {
								image = UIImage(data: imageData, scale: UIScreen.main.scale)
							}
							
							performOnQueue(configQueue) { success?(image) } },
		                progress: { (bytes: Int, totalBytes: Int, data: Data?) in
							performOnQueue(configQueue) { progress?(bytes, totalBytes, data) } },
		                error: { (err: RequestError) in
							performOnQueue(configQueue) { error?(err) } })
	}
		
	/*
	+ (instancetype)downloadStringAsync: (NSString *)stringUrl context: (id)contextKey success (RequestSuccessBlock)successBlock progress:(RequestProgressBlock)progressBlock error:(RequestErrorBlock)errorBlock
	{
		return [self downloadAsync:stringUrl withErrorDelegate:nil contentType:@"text/plain" withParameters:nil context:contextKey success:successBlock progress:progressBlock error:errorBlock];
	}
	*/
	
	// CachePath is relative path. CachePath can has following values:
	// * Dir/ - Dir will be used as cache section name/sub-directory and entire cache directory will be deleted
	// * /File - File will be used as file name in cache root directory and file will be deleted
	// * /Dir/File - Dir will be used as cache section name/sub-directory and file will be removed by name by following path: cache root dir + dir
	// MARK: - Public methods
	
	static func removeCache(cachePath: String) {
		CacheManager.globalCache.removeCache(forPath: cachePath)
	}
	
	// MARK: - Private methods
	
	private static func fileName(for urlComponents: URLComponents, headers: [String: String]?, parameters: Any?) -> String {
		var fileName = urlComponents.url!.lastPathComponent
		
		if let headers = headers {
			var headersHash = 0
			for (key, value) in headers {
				headersHash += key.hashValue ^ value.hashValue
			}
			
			fileName += "_\(headersHash)"
		}
		
		if let queryItems = urlComponents.queryItems {
			var existedQueryItemsHash = 0
			for queryItem in queryItems {
				existedQueryItemsHash += queryItem.name.hashValue ^ (queryItem.value?.hashValue ?? 0)
			}
			
			fileName += "_\(existedQueryItemsHash)"
		}
		
		if let parameters = parameters {
			
			func calculateHashForArray(_ array: [AnyHashable]) -> Int {
				var hashValue = 0
				for element in array {
					if element is [String: AnyHashable] {
						hashValue ^= calculateHashForDictionary(element as! [String: AnyHashable])
					} else {
						hashValue ^= element.hashValue
					}
				}
				return hashValue
			}
			
			func calculateHashForDictionary(_ dictionary: [String: AnyHashable]) -> Int {
				var hashValue = 0
				for (key, value) in dictionary {
					if value is [AnyHashable] {
						hashValue += key.hashValue ^ calculateHashForArray(value as! [AnyHashable])
					} else if value is [String: AnyHashable] {
						hashValue += key.hashValue ^ calculateHashForDictionary(value as! [String: AnyHashable])
					} else {
						hashValue += key.hashValue ^ value.hashValue
					}
				}
				return hashValue
			}
			
			var parametersHash = 0
			if let parametersDictionary = parameters as? [String: AnyHashable] {
				parametersHash = calculateHashForDictionary(parametersDictionary)
			} else if let parametersArray = parameters as? [AnyHashable] {
				parametersHash = calculateHashForArray(parametersArray)
			} else if let hashableParameters = parameters as? AnyHashable {
				parametersHash = hashableParameters.hashValue
			}
			
			fileName += "_\(parametersHash)"
		}
		
		return fileName
	}
	
	private static func relativePath(for url: String, path: String?, headers: [String: String]?, parameters: Any?) -> String {
		if let path = path, !path.hasSuffix("/") {
			return path
		}
		
		let urlComponents = URLComponents(string: url)!
		let fileName = self.fileName(for: urlComponents, headers: headers, parameters: parameters)
		
		if let path = path, !path.isEmpty {
			return (path as NSString).appendingPathComponent(fileName)
		} else {
			let urlPath = urlComponents.path
			let directory = String(urlPath.prefix(upTo: urlPath.index(before: urlPath.reversed().index(of: "/")!.base)))
			
			return (((urlComponents.url!.host! as NSString).appendingPathComponent(directory)) as NSString).appendingPathComponent(fileName)
		}
	}
	
	private static func fileHandle(for filePath: String) -> FileHandle? {
		let fileManager: FileManager = FileManager.default
		let path = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(filePath)
		
		if !fileManager.fileExists(atPath: path) {
			try! fileManager.createDirectory(atPath: (path as NSString).deletingLastPathComponent, withIntermediateDirectories: true, attributes: nil)
			
			let fileCreated: Bool = fileManager.createFile(atPath: path, contents: nil, attributes: nil)
			if !fileCreated {
				NSException(
					name: .internalInconsistencyException,
					reason: "Error creating file: \(path)",
					userInfo: nil).raise()
			}
		}
		
		let fileHandle = FileHandle(forWritingAtPath: path)
		
		// Clean previous data in file
		fileHandle?.truncateFile(atOffset: 0)
		
		return fileHandle
	}
	
	private static func performOnQueue(_ queue: DispatchQueue?, block: @escaping () -> ()) {
		if let queue = queue {
			queue.async { block() }
		} else {
			block()
		}
	}
	
	private static func htmlDateString(for date: Date?) -> String {
		guard let date = date else { return "" }
		
		let df = DateFormatter()
		df.locale = Locale(identifier: "en_US")
		df.timeZone = TimeZone(abbreviation: "GMT")
		df.dateFormat = "EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'"
		
		return df.string(from: date)
	}
	
	private static func getFileSize(for url: String,
	                                usePreload: Bool,
	                                contextKey: AnyHashable?,
	                                success: RequestSuccessBlock?,
	                                error: RequestErrorBlock?) -> RequestManager? {
		var reqMan: RequestManager?
		if usePreload {
			let headers = ["Content-Type" : "application/octet-stream"]
//			reqMan = performRequest(requestPath: url,
//			                        configuration: nil,
//			                        errorDelegate: nil,
//			                        headers: headers,
//			                        parameters: nil,
//			                        method: "GET",
//			                        contextKey: contextKey,
//			                        success: nil,
//			                        progress: { (bytes: Int, totalBytes: Int, data: Data?) in
//										success?(totalBytes as AnyObject)
//										reqMan?.cancelConnection() },
//			                        error: error)
		} else {
			/*
			if let url = URL(string: url) {
				var request = URLRequest(url: url)
				request.httpMethod = "HEAD"
				
				URLSession.shared.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, err: Error?) in
					if let e = err, error != nil {
						let requestErr = RequestError()
						requestErr.error = e as NSError
						error?(requestErr)
					} else {
						success?(response?.expectedContentLength as AnyObject)
					} }
				).resume()
			}
			*/
			reqMan = performRequest(path: url,
			                        method: "HEAD",
			                        headers: nil,
			                        parameters: nil,
			                        errorDelegate: nil,
			                        contextKey: contextKey,
			                        success: { (dataObj: Any) in
//										let contentLength = reqMan?.expectedContentLength
//										success?(contentLength as AnyObject)
										},
			                        progress: nil,
			                        error: error)
		}
		
		return reqMan
	}
	
}
