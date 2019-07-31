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
/// `Book` represents a specific manga.
///
final public class Book : Codable, Comparable, CustomStringConvertible
{
	///
	/// The identifier used by the remote API
	/// to identify this book.
	///
	/// This value is also known as the "slug"
	///
	public fileprivate(set) var identifier: String

	///
	/// Title of the book.
	///
	public fileprivate(set) var title: String

	///
	/// Author of the book.
	///
	public fileprivate(set) var author: String

	///
	/// Artist of the book.
	///
	public fileprivate(set) var artist: String

	///
	/// Description of the book.
	///
	public fileprivate(set) var summary: String

	///
	/// Cover image of the book.
	///
	public fileprivate(set) var cover: URL

	///
	/// All volumes for the book.
	///
	/// Even for chapters that are part of an unfinished
	/// volume, they are still stored within a `Volume`.
	/// The `Volume` for ongoing chapters have a nil `number`.
	///
	public fileprivate(set) var volumes: Volumes {
		willSet (volumes) {
			volumes.forEach { $0.assignBook(self) }
		}
	}

	///
	/// String representation of `Book`.
	///
	public var description: String
	{
		return """
		Book(
			identifier: '\(identifier)',
			title: '\(title)',
			author: '\(author)',
			artist: '\(artist)',
			description: '\(summary)',
			cover image: '\(cover)',
			volumes:
				'\(volumes)'
		)
		"""
	}

	///
	/// See description of `BookMutable`
	///
	fileprivate init (with mutableBook: BookMutable) throws
	{
		identifier 		= try assignOrThrow(mutableBook.identifier)
		title 			= try assignOrThrow(mutableBook.title)
		author			= try assignOrThrow(mutableBook.author)
		artist 			= try assignOrThrow(mutableBook.artist)
		summary 		= try assignOrThrow(mutableBook.summary)
		cover 			= try assignOrThrow(mutableBook.cover)
		volumes 		= try assignOrThrow(mutableBook.volumes).sorted(by: <)
	}

	///
	/// Sort by `title`.
	///
	public static func < (lhs: Book, rhs: Book) -> Bool
	{
		return lhs.title < rhs.title
	}

	///
	/// Equal if both are the same reference.
	///
	public static func == (lhs: Book, rhs: Book) -> Bool
	{
		return lhs === rhs
	}
}

///
/// `Books` is a collection of `Book`.
///
public typealias Books = [Book]

///
/// `Book` data is splintered across multiple API requests which
/// means we cannot easily create an immutable `Book` without a
/// temporary buffer. `BookMutable` is this buffer. All properties
/// in it mirror those of `Book` and are optional.
///
/// When the buffer is full, we can then create an instance of
/// `Book` by calling the `copy()` function.
///
final class BookMutable
{
	var identifier: String?
	var title: String?
	var author: String?
	var artist: String?
	var summary: String?
	var cover: URL?
	var volumes: [Volume]?

	///
	/// Create a new instance of `Book` using the
	/// properties stored within the mutable object.
	///
	/// `Book` expects many values to be non-nil
	/// which means copying will throw an error if
	/// those values are nil during copy.
	///
	/// Throws:
	///   - `MutabilityError.nilValue`
	///
	func copy() throws -> Book
	{
		return try Book(with: self)
	}
}
