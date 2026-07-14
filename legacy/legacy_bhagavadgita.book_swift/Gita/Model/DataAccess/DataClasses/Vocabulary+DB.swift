//
//  Vocabulary+DB.swift
//  Gita
//
//  Created by Olga Zhegulo  on 19/05/17.
//  Copyright © 2017 Iron Water Studio. All rights reserved.
//

import Foundation

extension Vocabulary {
	
	static func insertAll(connection conn: DbConnection, vocabularies: [Vocabulary]) {
		if vocabularies.count == 0 {
			return
		}
		
		for v in vocabularies {
			_ = v.insert(connection: conn)
		}
	}

	func insert(connection conn: DbConnection) -> Int {
		let cmd = DbCommand(connection: conn)
		//NOTE: vocabulary Id will be assigned automatically
		cmd.text = "INSERT INTO Vocabularies (SlokaId, Text, Translation) VALUES(:SlokaId, :Text, :Translation)"
		
		cmd.parameters.append(DbParameter(name: ":SlokaId", value: self.shlokaId))
		cmd.parameters.append(DbParameter(name: ":Text", value: self.text))
		cmd.parameters.append(DbParameter(name: ":Translation", value: self.translation))
		cmd.executeNonQuery()
		
		return cmd.lastInsertedId()
	}
}
