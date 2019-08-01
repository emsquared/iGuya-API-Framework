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
final public class Chapter : Codable, Comparable, CustomStringConvertible
{
	///
	/// The volume the chapter belongs to.
	///
	public fileprivate(set) weak var volume: Volume?

	///
	/// Number of the chapter.
	///
	public fileprivate(set) var number: String

	///
	/// Title of the chapter.
	///
	public fileprivate(set) var title: String

	///
	/// All releases for the chapter.
	///
	public fileprivate(set) var releases: Releases {
		willSet (releases) {
			releases.forEach { $0.assignChapter(self) }
		}
	}

	///
	/// Create a new instance of `Volume`.
	///
	init (volume: Volume?, number: String, title: String, releases: Releases)
	{
		self.volume = volume
		self.number = number
		self.title = title
		self.releases = releases.sorted(by: <)
	}

	///
	/// `Chapter` objects are created before `Volume` objects.
	/// `assignVolume()` assigns a `Volume` object once it
	/// becomes available.
	///
	/// This function only assigns the volume if none is set.
	///
	/// This function is automatically called by the `willSet`
	/// handler for the `chapters` property in `Volume`.
	/// There is no need to call it directly.
	///
	/// - Parameter volume: The volume the chapter belongs to.
	///
	func assignVolume(_ volume: Volume)
	{
		if self.volume == nil {
			self.volume = volume
		}
	}

	///
	/// String representation of `Chapter`.
	///
	public var description: String
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
	public static func < (lhs: Chapter, rhs: Chapter) -> Bool
	{
		let number1 = lhs.number
		let number2 = rhs.number

		return number1.compareAsDouble(number2, <)
	}

	///
	/// Equal if both are the same reference.
	///
	public static func == (lhs: Chapter, rhs: Chapter) -> Bool
	{
		return lhs === rhs
	}
}

///
/// `Chapters` is a collection of `Chapter`.
///
public typealias Chapters = [Chapter]

/* ------------------------------------------------------ */

public extension Chapter
{
	///
	/// A chapter can have multiple releases.
	/// Such as one from a JP -> KR -> EN group.
	/// And one from a JP -> EN group.
	/// `Release` represents a specific release.
	///
	class Release : Codable, Comparable, CustomStringConvertible
	{
		///
		/// The chapter the release belongs to.
		///
		public fileprivate(set) weak var chapter: Chapter?

		///
		/// The group that created the release.
		///
		public fileprivate(set) var group: Group

		///
		/// List of pages, in order, for the release.
		///
		public fileprivate(set) var pages: Pages {
		   willSet (pages) {
			   pages.forEach { $0.assignRelease(self) }
		   }
	   }

		///
		/// Create a new instance of `Volume`.
		///
		init (chapter: Chapter?, group: Group, pages: Pages)
		{
			self.chapter = chapter
			self.group = group
			self.pages = pages
		}

		///
		/// `Release` objects are created before `Chapter` objects.
		/// `assignChapter()` assigns a `Chapter` object once it
		/// becomes available.
		///
		/// This function only assigns the release if none is set.
		///
		/// This function is automatically called by the `willSet`
		/// handler for the `releases` property in `Chapter`.
		/// There is no need to call it directly.
		///
		/// - Parameter chapter: The chapter the release belongs to.
		///
		fileprivate func assignChapter(_ chapter: Chapter)
		{
			if self.chapter == nil {
				self.chapter = chapter
			}
		}

		///
		/// String representation of `Release`.
		///
		public var description: String
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
		public static func < (lhs: Release, rhs: Release) -> Bool
		{
			return lhs.group < rhs.group
		}

		///
		/// Equal if both are the same reference.
		///
		public static func == (lhs: Release, rhs: Release) -> Bool
		{
			return lhs === rhs
		}
	}

	///
	/// `Releases` is a collection of `Release`.
	///
	typealias Releases = [Release]
}

public extension Chapter.Release
{
	///
	/// `Page` represents a specific page in a release.
	///
	class Page : Codable, Comparable, CustomStringConvertible
	{
		///
		/// The release the page belongs to.
		///
		public fileprivate(set) weak var release: Chapter.Release?

		///
		/// The page number.
		///
		public fileprivate(set) var number: Int

		///
		/// URL of full size image for the page.
		///
		public fileprivate(set) var page: URL

		///
		/// URL of scaled preview image for the page.
		///
		public fileprivate(set) var preview: URL

		///
		/// Create a new instance of `Volume`.
		///
		init (release: Chapter.Release?, number: Int, page: URL, preview: URL)
		{
			self.release = release
			self.number = number
			self.page = page
			self.preview = preview
		}

		///
		/// `Page` objects are created before `Release` objects.
		/// `assignRelease()` assigns a `Release` object once it
		/// becomes available.
		///
		/// This function only assigns the release if none is set.
		///
		/// This function is automatically called by the `willSet`
		/// handler for the `pages` property in `Release`.
		/// There is no need to call it directly.
		///
		/// - Parameter release: The release the page belongs to.
		///
		fileprivate func assignRelease(_ release: Chapter.Release)
		{
			if self.release == nil {
				self.release = release
			}
		}

		///
		/// String representation of `Release`.
		///
		public var description: String
		{
			return """
			Page(
				number: '\(number)'
				page: '\(page)'
				preview: '\(preview)'
			)
			"""
		}

		///
		/// Sort by `number`.
		///
		public static func < (lhs: Page, rhs: Page) -> Bool
		{
			return lhs.number < rhs.number
		}

		///
		/// Equal if both are the same reference.
		///
		public static func == (lhs: Page, rhs: Page) -> Bool
		{
			return lhs === rhs
		}
	}

	///
	/// `Pages` is a collection of `Page`.
	///
	typealias Pages = [Page]
}
