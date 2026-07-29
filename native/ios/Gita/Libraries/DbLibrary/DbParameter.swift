//
//  DbParameter.swift
//  DbLibrary
//
//  Created by Roman Developer on 7/24/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import UIKit

class DbParameter {
	let name: String
	let value: Any
	
	required init(name: String, value: Any) {
		self.name = name
		self.value = value
	}
}

