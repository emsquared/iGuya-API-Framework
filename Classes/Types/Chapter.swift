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
/// `Chapter` represents a specific chapter in `volume`
///
final public class Chapter: NSObject, Codable, Comparable, EquatableByReference
{
	///
	/// The volume the chapter belongs to.
	///
	@objc
	public fileprivate(set) weak var volume: Volume?

	///
	/// Number of the chapter.
	///
	@objc
	public fileprivate(set) var number: Double

	///
	/// Title of the chapter.
	///
	@objc
	public fileprivate(set) var title: String

	///
	/// All releases for the chapter.
	///
	@objc
	public fileprivate(set) var releases: Releases

	///
	/// All groups that have a release for the chapter.
	///
	@objc
	lazy public var groups: Groups =
	{
		var groups: Groups = []

		releases.forEach { groups.append($0.group) }

		return groups
	}()

	///
	/// The folder in which the pages are saved.
	///
	@objc
	public fileprivate(set) var folder: String

	///
	/// Create a new instance of `Volume`.
	///
	init (volume: Volume? = nil, number: Double, title: String, releases: Releases, folder: String)
	{
		self.volume = volume
		self.number = number
		self.title = title
		self.releases = releases
		self.folder = folder

		super.init()

		finalizeProperties()
	}

	///
	/// Perform last second cleanup of properties during `init()`.
	///
	fileprivate func finalizeProperties()
	{
		assignToChildren()

		releases.sort(by: <)
	}

	///
	/// Override coding keys to prevent loops caused by parent references.
	///
	private enum CodingKeys: String, CodingKey
	{
		case number
		case title
		case releases
		case folder
	}

	///
	/// Assign reference to children objects.
	///
	func assignToChildren()
	{
		releases.forEach { $0.assignParent(self) }
	}

	///
	/// Assign reference to parent object.
	///
	func assignParent(_ parent: Volume)
	{
		if volume == nil {
			volume = parent
		}
	}

	///
	/// String representation of `Chapter`.
	///
	override public var description: String
	{
		return """
		Chapter(
			number: '\(number)',
			title: '\(title)',
			releases:
				\(releases)
		)
		"""
	}

	///
	/// Sort by `number`.
	///
	static public func < (lhs: Chapter, rhs: Chapter) -> Bool
	{
		return lhs.number < rhs.number
	}
}

///
/// `Chapters` is a collection of `Chapter`.
///
public typealias Chapters = [Chapter]
