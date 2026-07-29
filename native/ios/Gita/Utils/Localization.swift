//
//  Localization.swift
//  Tomato
//
//  Created by Konstantin Oznobikhin on 11/04/16.
//  Copyright © 2016 ironwaterstudio. All rights reserved.
//

import Foundation

public func Local(_ key: String) -> String {
	return NSLocalizedString(key, comment: "")
}

//Solution from http://www.iphones.ru/forum/index.php?showtopic=76119
// n - integer, s1 - form for 1 unit, s2 - form for 2-4, s5 - form for 5-19 unit
//#define XXX(n,s1,s2,s5) (((5 <= (labs(n)%100)) && ((labs(n)%100)<=20)) ? (s5) : ((labs(n)%10==1) ? (s1) : (((2<=(labs(n)%10))&&((labs(n)%10)<=4)) ? (s2) :(s5))))

/* //If multiple toppings wording in shopping appear invalid in IOS8
public func formatQuantity(number n: Int, one: String, two: String, other: String) -> String {
	return (((5 <= (labs(n)%100)) && ((labs(n)%100)<=20)) ? other : ((labs(n)%10==1) ? one : (((2<=(labs(n)%10))&&((labs(n)%10)<=4)) ? two :other)))
}
*/
