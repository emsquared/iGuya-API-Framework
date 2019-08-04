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
final public class Chapter : NSObject, Codable, Comparable
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
	public fileprivate(set) var number: String

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
	public var groups: Groups
	{
		var groups: Groups = []

		releases.forEach { groups.append($0.group) }

		return groups
	}

	///
	/// The folder in which the pages are saved on guya.moe.
	///
	fileprivate var folder: String

	///
	/// Create a new instance of `Volume`.
	///
	init (volume: Volume? = nil, number: String, title: String, releases: Releases, folder: String)
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
		releases.forEach { $0.assignChapter(self) }
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
	/// `Chapter` objects are created before `Volume` objects.
	/// `assignVolume()` assigns a `Volume` object once it
	/// becomes available.
	///
	/// This function only assigns the volume if none is set.
	///
	/// This function is automatically called.
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
	public static func < (lhs: Chapter, rhs: Chapter) -> Bool
	{
		return lhs.number.compareAsDouble(rhs.number, <)
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
	class Release : NSObject, Codable, Comparable
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
			pages.forEach { $0.assignRelease(self) }
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
		/// `Release` objects are created before `Chapter` objects.
		/// `assignChapter()` assigns a `Chapter` object once it
		/// becomes available.
		///
		/// This function only assigns the release if none is set.
		///
		/// This function is automatically called.
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
	@objc
	class Page : NSObject, Codable, Comparable
	{
		///
		/// The release the page belongs to.
		///
		/* Different name for Objective-C because it was having a
		 conflict with a `release()` function in `Codable`. */
		@objc(releaseRef)
		public fileprivate(set) weak var release: Chapter.Release?

		///
		/// The file as which the pages are saved on guya.moe.
		///
		fileprivate var file: String

		///
		/// The page number.
		///
		@objc
		public fileprivate(set) var number: Int

		///
		/// URL of full size image for the page.
		///
		/// This property is computed on the fly which is why
		/// it can return `nil`. It might not always have enough
		/// context at the time it's called.
		///
		@objc
		public var page: URL?
		{
			/* Now this is what you call chaining... */
			guard 	let release = release,
					let chapter = release.chapter,
					let identifier = chapter.volume?.book?.identifier else {
				return nil
			}

			return Linkify.release(with: file, in: chapter.folder, by: release.group, identifier: identifier)
		}

		///
		/// URL of scaled preview image for the page.
		///
		/// This property is computed on the fly which is why
		/// it can return `nil`. It might not always have enough
		/// context at the time it's called.
		///
		@objc
		public var preview: URL?
		{
			/* Now this is what you call chaining... */
			guard 	let release = release,
					let chapter = release.chapter,
					let identifier = chapter.volume?.book?.identifier else {
				return nil
			}

			return Linkify.preview(with: file, in: chapter.folder, by: release.group, identifier: identifier)
		}
		///
		/// URL of the page onnline at guya.moe.
		///
		/// This property is computed on the fly which is why
		/// it can return `nil`. It might not always have enough
		/// context at the time it's called.
		///
		@objc
		public var webpage: URL?
		{
			guard 	let chapter = release?.chapter,
					let identifier = chapter.volume?.book?.identifier else {
				return nil
			}

			return Linkify.share(page: number, in: chapter.number, identifier: identifier)
		}

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
		init (release: Chapter.Release? = nil, number: Int, file: String)
		{
			self.release = release
			self.number = number
			self.file = file

			super.init()
		}

		///
		/// `Page` objects are created before `Release` objects.
		/// `assignRelease()` assigns a `Release` object once it
		/// becomes available.
		///
		/// This function only assigns the release if none is set.
		///
		/// This function is automatically called.
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
		override public var description: String
		{
			return """
			Page(
				number: '\(number)'
				page: '\(String(describing: page))'
				preview: '\(String(describing: preview))'
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
