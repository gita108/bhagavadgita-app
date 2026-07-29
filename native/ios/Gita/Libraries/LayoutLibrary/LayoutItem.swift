//
//  LayoutItem.swift
//  TopPlace
//
//  Created by Denis on 08.11.16.
//  Copyright © 2016 IronWaterStudio. All rights reserved.
//

import UIKit

/// Fake types for using generics
public enum XAxis {}
public enum YAxis {}
public enum Dimension {}

/// LayoutItem is an abstraction above view's layout attributes
/// It can represent only one attribute for one view at time
///
///	Use overloaded operations +, - to mutate
/// LayoutItem instance constant value
///
///	Use overloaded operations *, / to mutate
/// LayoutItem instance multiplier value
///
/// Use overloaded operations ==, >=, <=
/// to get constraint from two LayoutItem instances
public struct LayoutItem<T> {
	
	fileprivate let item: UIView
	fileprivate let attribute: NSLayoutAttribute
	fileprivate let multiplier: CGFloat
	fileprivate let constant: CGFloat
	
	fileprivate func constrain(withRelation relation: NSLayoutRelation, toItem layoutItem: LayoutItem) -> NSLayoutConstraint {
		item.translatesAutoresizingMaskIntoConstraints = false
		
		return NSLayoutConstraint(item: item,
		                          attribute: attribute,
		                          relatedBy: relation,
		                          toItem: layoutItem.item,
		                          attribute: layoutItem.attribute,
		                          multiplier: layoutItem.multiplier,
		                          constant: layoutItem.constant)
	}
	
	fileprivate func constrain(withRelation relation: NSLayoutRelation, toValue value: CGFloat) -> NSLayoutConstraint {
		item.translatesAutoresizingMaskIntoConstraints = false
		
		return NSLayoutConstraint(item: item,
		                          attribute: attribute,
		                          relatedBy: relation,
		                          toItem: nil,
		                          attribute: .notAnAttribute,
		                          multiplier: multiplier,
		                          constant: value)
	}
	
	fileprivate func item(withConstant constant: CGFloat) -> LayoutItem {
		return LayoutItem(item: item, attribute: attribute, multiplier: multiplier, constant: constant)
	}
	
	fileprivate func item(withMultiplier multiplier: CGFloat) -> LayoutItem {
		return LayoutItem(item: item, attribute: attribute, multiplier: multiplier, constant: constant)
	}

}

// MARK: - Common operations

public func * <T>(lhs: LayoutItem<T>, rhs: CGFloat) -> LayoutItem<T> {
	return lhs.item(withMultiplier: lhs.multiplier * rhs)
}

public func / <T>(lhs: LayoutItem<T>, rhs: CGFloat) -> LayoutItem<T> {
	return lhs.item(withMultiplier: lhs.multiplier / rhs)
}

public func + <T>(lhs: LayoutItem<T>, rhs: CGFloat) -> LayoutItem<T> {
	return lhs.item(withConstant: lhs.constant + rhs)
}

public func - <T>(lhs: LayoutItem<T>, rhs: CGFloat) -> LayoutItem<T> {
	return lhs.item(withConstant: lhs.constant - rhs)
}

public func == <T>(lhs: LayoutItem<T>, rhs: LayoutItem<T>) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .equal, toItem: rhs)
}

public func >= <T>(lhs: LayoutItem<T>, rhs: LayoutItem<T>) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .greaterThanOrEqual, toItem: rhs)
}

public func <= <T>(lhs: LayoutItem<T>, rhs: LayoutItem<T>) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .lessThanOrEqual, toItem: rhs)
}

// MARK: - Operations for dimension constraints

public func == (lhs: LayoutItem<Dimension>, rhs: CGFloat) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .equal, toValue: rhs)
}

public func >= (lhs: LayoutItem<Dimension>, rhs: CGFloat) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .greaterThanOrEqual, toValue: rhs)
}

public func <= (lhs: LayoutItem<Dimension>, rhs: CGFloat) -> NSLayoutConstraint {
	return lhs.constrain(withRelation: .lessThanOrEqual, toValue: rhs)
}

// MARK: - LayoutItem support for UIView

fileprivate func layoutItem<T>(for view: UIView, withAttribute attribute: NSLayoutAttribute) -> LayoutItem<T> {
	return LayoutItem(item: view, attribute: attribute, multiplier: 1.0, constant: 0.0)
}

public extension UIView {
	
	public var leftItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .left)
	}
	
	public var rightItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .right)
	}
	
	public var topItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .top)
	}
	
	public var bottomItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .bottom)
	}
	
	public var leadingItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .leading)
	}
	
	public var trailingItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .trailing)
	}

	public var widthItem: LayoutItem<Dimension> {
		return layoutItem(for: self, withAttribute: .width)
	}
	
	public var heightItem: LayoutItem<Dimension> {
		return layoutItem(for: self, withAttribute: .height)
	}
	
	public var centerXItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .centerX)
	}
	
	public var centerYItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .centerY)
	}
	
	public var lastBaseLineItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .lastBaseline)
	}
	
	@available(iOS 8.0, *)
	public var firstBaselineItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .firstBaseline)
	}
	
	@available(iOS 8.0, *)
	public var leftMarginItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .leftMargin)
	}
	
	@available(iOS 8.0, *)
	public var rightMarginItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .rightMargin)
	}
	
	@available(iOS 8.0, *)
	public var topMarginItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .topMargin)
	}
	
	@available(iOS 8.0, *)
	public var bottomMarginItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .bottomMargin)
	}
	
	@available(iOS 8.0, *)
	public var leadingMarginItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .leadingMargin)
	}
	
	@available(iOS 8.0, *)
	public var trailingMarginItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .trailingMargin)
	}
	
	@available(iOS 8.0, *)
	public var centerXWithinMarginsItem: LayoutItem<XAxis> {
		return layoutItem(for: self, withAttribute: .centerXWithinMargins)
	}
	
	@available(iOS 8.0, *)
	public var centerYWithinMarginsItem: LayoutItem<YAxis> {
		return layoutItem(for: self, withAttribute: .centerYWithinMargins)
	}

}

// MARK: - NSLayoutConstraint Helpers

public func activateConstraints(_ constraints: NSLayoutConstraint...) {
	NSLayoutConstraint.activate(constraints)
}

public func deactivateConstraints(_ constraints: NSLayoutConstraint...) {
	NSLayoutConstraint.deactivate(constraints)
}

precedencegroup PriorityPrecedence {
	associativity: left
	lowerThan: ComparisonPrecedence
}

infix operator ~: PriorityPrecedence

public func ~ (lhs: NSLayoutConstraint, rhs: Float) -> NSLayoutConstraint {
	let constraint = NSLayoutConstraint(item: lhs.firstItem!,
	                                    attribute: lhs.firstAttribute,
	                                    relatedBy: lhs.relation,
	                                    toItem: lhs.secondItem!,
	                                    attribute: lhs.secondAttribute,
	                                    multiplier: lhs.multiplier,
	                                    constant: lhs.constant)
	#if swift(>=4.0)
		constraint.priority = UILayoutPriority(rawValue: rhs)
	#else
		constraint.priority = rhs
	#endif

	return constraint
}
