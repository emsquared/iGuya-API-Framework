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
/// `Page` represents a specific page in a release.
///
@objc
final public class Page: NSObject, Codable, Comparable, EquatableByReference
{
	///
	/// The release the page belongs to.
	///
	/* Different name for Objective-C because it was having a
	 conflict with a `release()` function in `Codable`. */
	@objc(releaseRef)
	public fileprivate(set) weak var release: Release?

	///
	/// The page number.
	///
	@objc
	public fileprivate(set) var number: Int

	///
	/// The page file name.
	///
	@objc
	public fileprivate(set) var file: String

	///
	/// Override coding keys to prevent loops caused by parent references.
	///
	private enum CodingKeys: String, CodingKey
	{
		case file
		case number
	}

	///
	/// Create a new instance of `Volume`.
	///
	init (release: Release? = nil, number: Int, file: String)
	{
		self.release = release
		self.number = number
		self.file = file

		super.init()
	}

	///
	/// Assign reference to parent object.
	///
	func assignParent(_ parent: Release)
	{
		if release == nil {
			release = parent
		}
	}

	///
	/// String representation of `Release`.
	///
	override public var description: String
	{
		return "Page(number: \(number))"
	}

	///
	/// Sort by `number`.
	///
	static public func < (lhs: Page, rhs: Page) -> Bool
	{
		return lhs.number < rhs.number
	}
}

///
/// `Pages` is a collection of `Page`.
///
public typealias Pages = [Page]
