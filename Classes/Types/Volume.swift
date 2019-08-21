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
/// `Volume` represents a specific volume in `book`
///
@objc
final public class Volume: NSObject, Codable, Comparable, EquatableByReference
{
	///
	/// The book the volume belongs to.
	///
	/// This is a weak reference.
	///
	@objc
	public fileprivate(set) weak var book: Book?

	///
	/// The volume number.
	///
	@objc
	public fileprivate(set) var number: Int

	///
	/// Chapters the volume contains.
	///
	/// The order of this collection is stable.
	/// It is sorted by ascending chapter number.
	///
	@objc
	public fileprivate(set) var chapters: Chapters

	///
	/// Create a new instance of `Volume`.
	///
	init (book: Book? = nil, number: Int, chapters: Chapters)
	{
		self.book = book
		self.number = number
		self.chapters = chapters

		super.init()

		finalizeProperties()
	}

	///
	/// Perform last second cleanup of properties during `init()`.
	///
	fileprivate func finalizeProperties()
	{
		assignToChildren()

		chapters.sort(by: <)
	}

	///
	/// Override coding keys to prevent loops caused by parent references.
	///
    private enum CodingKeys: String, CodingKey
	{
        case number
        case chapters
    }

	///
	/// Assign reference to children objects.
	///
	func assignToChildren()
	{
		chapters.forEach { $0.assignParent(self) }
	}

	///
	/// Assign reference to parent object.
	///
	func assignParent(_ parent: Book)
	{
		if book == nil {
			book = parent
		}
	}

	///
	/// String representation of `Volume`.
	///
	override public var description: String
	{
		return """
		Volume(
			number: '\(number)',
			chapters:
				\(chapters)
		)
		"""
	}

	///
	/// Sort by `number`.
	///
	static public func < (lhs: Volume, rhs: Volume) -> Bool
	{
		return lhs.number < rhs.number
	}
}

///
/// `Volumes` is a collection of `Volume`.
///
public typealias Volumes = [Volume]
