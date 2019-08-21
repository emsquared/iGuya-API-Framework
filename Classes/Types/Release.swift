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

///
/// A chapter can have multiple releases.
/// Such as one from a JP -> KR -> EN group.
/// And one from a JP -> EN group.
/// `Release` represents a specific release.
///
final public class Release: NSObject, Codable, Comparable, EquatableByReference
{
	///
	/// The chapter the release belongs to.
	///
	@objc
	public fileprivate(set) weak var chapter: Chapter?

	///
	/// The group that created the release.
	///
	@objc
	public fileprivate(set) var group: Group

	///
	/// List of pages, in order, for the release.
	///
	/// The order of this collection is stable.
	/// It is sorted by ascending page number.
	///
	@objc
	public fileprivate(set) var pages: Pages

	///
	/// Create a new instance of `Volume`.
	///
	init (chapter: Chapter? = nil, group: Group, pages: Pages)
	{
		self.chapter = chapter
		self.group = group
		self.pages = pages

		super.init()

		finalizeProperties()
	}

	///
	/// Perform last second cleanup of properties during `init()`.
	///
	fileprivate func finalizeProperties()
	{
		assignToChildren()

		pages.sort(by: <)
	}

	///
	/// Override coding keys to prevent loops caused by parent references.
	///
	private enum CodingKeys: String, CodingKey
	{
		case group
		case pages
	}

	///
	/// Assign reference to children objects.
	///
	func assignToChildren()
	{
		pages.forEach { $0.assignParent(self) }
	}

	///
	/// Assign reference to parent object.
	///
	func assignParent(_ parent: Chapter)
	{
		if chapter == nil {
			chapter = parent
		}
	}

	///
	/// String representation of `Release`.
	///
	override public var description: String
	{
		return """
		Release(
			group: \(group),
			pages:
				\(pages)
		)
		"""
	}

	///
	/// Sort by `group`.
	///
	static public func < (lhs: Release, rhs: Release) -> Bool
	{
		return lhs.group < rhs.group
	}
}

///
/// `Releases` is a collection of `Release`.
///
public typealias Releases = [Release]
