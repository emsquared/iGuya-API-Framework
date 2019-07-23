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
/// `Series` represents a specific manga.
///
final public class Manga {
	///
	/// The identifier used by the remote API
	/// to identify this series.
	///
	/// This value is also known as the "slug"
	///
	public fileprivate(set) var identifier: String

	///
	/// Title of the series.
	///
	public fileprivate(set) var title: String

	///
	/// Author of the series.
	///
	public fileprivate(set) var author: String

	///
	/// Artist of the series.
	///
	public fileprivate(set) var artist: String

	///
	/// Description of the series.
	///
	public fileprivate(set) var description: String

	///
	/// Cover image of the series.
	///
	public fileprivate(set) var cover: URL

	///
	/// All volumes for the series.
	///
	/// Even for chapters that are part of an unfinished
	/// volume, they are still stored within a `Volume`.
	/// The `Volume` for ongoing chapters have a nil `number`.
	///
	public fileprivate(set) var volumes: Volumes

	///
	/// See description of `SeriesMutable`
	///
	fileprivate init (with mutableSeries: SeriesMutable) throws
	{
		identifier 		= try assignOrThrow(mutableSeries.identifier)
		title 			= try assignOrThrow(mutableSeries.title)
		author			= try assignOrThrow(mutableSeries.author)
		artist 			= try assignOrThrow(mutableSeries.artist)
		description 	= try assignOrThrow(mutableSeries.description)
		cover 			= try assignOrThrow(mutableSeries.cover)
		volumes 		= try assignOrThrow(mutableSeries.volumes)
	}
}

///
/// `Series` data is splintered across multiple API requests which
/// means we cannot easily create an immutable `Series` without a
/// temporary buffer. `SeriesMutable` is this buffer. All properties
/// in it mirror those of `Series` and are optional.
///
/// When the buffer is full, we can then create an instance of
/// `Series` by calling the `copy()` function.
///
final class SeriesMutable {
	var identifier: String?
	var title: String?
	var author: String?
	var artist: String?
	var description: String?
	var cover: URL?
	var volumes: [Volume]?

	///
	/// Create a new instance of `Series` using the
	/// properties stored within the mutable object.
	///
	/// `Series` expects many values to be non-nil
	/// which means copying will throw an error if
	/// those values are nil during copy.
	///
	/// Throws:
	///   - `MutabilityError.nilValue`
	///
	func copy() throws -> Manga
	{
		return try Manga(with: self)
	}
}
