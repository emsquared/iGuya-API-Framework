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

struct Linkify
{
	///
	/// Create URL of the image for a cover.
	///
	/// - Parameter file: Filename of the cover.
	///
	@inlinable
	static func cover(with file: String) -> URL?
	{
		let link = "https://ka.guya.moe\(file)"

		return URL(string: link)
	}

	///
	/// Create URL of the full size image for a page in a release.
	///
	/// - Parameter file: Filename of the page.
	/// - Parameter folder: Folder in which the page resides.
	/// - Parameter group: The group responsible for the release.
	/// - Parameter identifier: Identifier for the book in which the page resides.
	///
	@inlinable
	static func release(with file: String, in folder: String, by group: Group, identifier: String) -> URL?
	{
		let link = "https://ka.guya.moe/media/manga/\(identifier)/chapters/\(folder)/\(group.identifier)/\(file)"

		return URL(string: link)
	}

	///
	/// Create URL of the scaled preview image for a page in a release.
	///
	/// - Parameter file: Filename of the page.
	/// - Parameter folder: Folder in which the page resides.
	/// - Parameter group: The group responsible for the release.
	/// - Parameter identifier: Identifier for the book in which the page resides.
	///
	@inlinable
	static func preview(with file: String, in folder: String, by group: Group, identifier: String) -> URL?
	{
		let link = "https://ka.guya.moe/media/manga/\(identifier)/chapters/\(folder)/\(group.identifier)_shrunk/\(file)"

		return URL(string: link)
	}

	///
	/// Create URL of `page` in `chapter` for sharing.
	///
	/// - Parameter page: The page number.
	/// - Parameter chapter: The chapter number.
	/// - Parameter identifier: Identifier for the book in which the page resides.
	///
	@inlinable
	static func share(page: Int, in chapter: String, identifier: String) -> URL?
	{
		let link: String

		/* "Kaguya Wants To Be Confessed To" is the only book
		 that guya.moe supports short URLs for. */
		if (identifier == "Kaguya-Wants-To-Be-Confessed-To") {
			link = "https://ka.guya.moe/\(chapter)/\(page)"
		} else {
			link = "https://guya.moe/reader/series/\(identifier)/\(chapter)/\(page)"
		}

		return URL(string: link)
	}
} // Links
