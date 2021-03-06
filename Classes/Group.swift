/* *********************************************************************
 *                   _  _____
 *                  (_)/ ____|
 *                   _| |  __ _   _ _   _  __ _
 *                  | | | |_ | | | | | | |/ _` |
 *                  | | |__| | |_| | |_| | (_| |
 *                  |_|\_____|\__,_|\__, |\__,_|
 *                                   __/ |
 *                                  |___/
 *
 *               Copyright (c) 2019 Michael Morris
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 *
 *********************************************************************** */

import Foundation
import Dispatch

///
/// `Group` represents a specific scanlator group.
///
@objc
final public class Group: NSObject, Codable, Comparable, EquatableByReference
{
	///
	/// The identifier used by the remote API
	/// to identify this group.
	///
	@objc
	public fileprivate(set) var identifier: String

	///
	/// Name of the group.
	///
	@objc
	public fileprivate(set) var name: String

	///
	/// Create a new instance of `Group`.
	///
	init (identifier: String, name: String)
	{
		self.identifier = identifier
		self.name = name
	}

	//
	// Groups are consistent across the entire guya platform which means
	// we can use a factory to always return the same Group object.
	//
	// A dispatch queue is used in the factory to guarantee that the object
	// store is always accessed synchronously preventing race conditions.
	//
	// In reality this may be an over optimization.
	//
	fileprivate static var sharedGroups: [String: Group] = [:]

	fileprivate static let sharedGroupsQueue =
		DispatchQueue(label: "SharedGroupsQueue")

	@discardableResult
	static func createGroup(identifier: String, name: String) -> Group
	{
		var group: Group?

		sharedGroupsQueue.sync {
			group = sharedGroups[identifier]

			if (group == nil) {
				group = Group(identifier: identifier, name: name)

				sharedGroups[identifier] = group!
			}
		}

		return group!
	}

	///
	/// Group identified by`identifier`.
	///
	/// `Group` objects are created after first book is downloaded
	/// which means this function will return `nil` until then.
	///
	static public func group(with identifier: String) -> Group?
	{
		var group: Group?

		sharedGroupsQueue.sync {
			group = sharedGroups[identifier]
		}

		return group
	}

	///
	/// String representation of `Group`.
	///
	override public var description: String
	{
		return "Group('\(identifier)': '\(name)')"
	}

	///
	/// Sort by `name`.
	///
	static public func < (lhs: Group, rhs: Group) -> Bool
	{
		return lhs.name < rhs.name
	}
}

///
/// `Groups` is a collection of `Group`.
///
public typealias Groups = [Group]
