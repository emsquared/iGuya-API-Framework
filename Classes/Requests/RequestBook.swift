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
import os.log

final class RequestBook : RequestJSON<Book>
{
	override var taskLocation: String?
	{
		return "https://ka.guya.moe/api/series/\(identifier)/"
	}

	fileprivate(set) var identifier: String

	init? (_ named: String, _ completionHandler: @escaping CompletionHandler)
	{
		guard named.matches(#"^([\w-]+)$"#) else {
			return nil
		}

		self.identifier = named

		super.init(with: completionHandler)
	}

	///
	/// `Structures` defines the layout of objects in the JSON payload.
	///
	fileprivate struct Structures
	{
		typealias Groups = [String : String]
		typealias Chapter = [String : Any]
		typealias Chapters = [String : Chapter]
		typealias Release = [String]
		typealias Releases = [String : Release]
	}

	///
	/// Returns object of type `<T>` from key in data.
	///
	/// If the object does not exist or cannot be cast to type,
	/// then throws exception.
	///
	/// - Parameter named: Key of the object.
	/// - Parameter data: Collection in which object resides.
	///
	fileprivate func object<T>(named: String, in data: URLSession.JSONData) throws -> T
	{
		if let value = data[named] as? T {
			return value
		}

		os_log("'%@' is missing or in incorrect format.",
			   log: Logging.Subsystem.general, type: .fault, named)

		throw Failure.unimplemented
	}

	///
	/// Returns object of type `String` from key in data.
	///
	/// If the object does not exist or cannot be cast to `String`,
	/// then throws exception.
	///
	/// - Parameter named: Key of the object.
	/// - Parameter data: Collection in which object resides.
	///
	/// - SeeAlso: object(named:, in:)
	///
	fileprivate func string(named: String, in data: URLSession.JSONData) throws -> String
	{
		return try object(named: named, in: data)
	}

	///
	/// Called if request succeeds.
	///
	override func taskCompleted(with data: URLSession.JSONData)
	{
		do {
			let book = try processBook(in: data)

			completionHandler(.success(book))

		/* Catch errors from our own framework. */
		} catch let error as Failure {
			os_log("Error caught: %@",
				   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

			completionHandler(.failure(.unimplemented))

		/* Catch all other errors. */
		} catch let error {
			/* TODO: Add a case for non-Failure errors to wrap them. */

			os_log("Unusual error caught: %@",
				   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

			completionHandler(.failure(.unimplemented))
		}
	}

	/**
		Parse object for a book.

		Example:
		```
		"chapters": {
			"1": {
				"volume": "1",
				"title": "I Want to be Invited to a Movie",
				"folder": "0001_9rr4clfz",
				"groups": {
					...
				}
				...
			"2": {
				"volume": "1",
				"title": "I Want to Play Old Maid",
				"folder": "0002_nih78b9p",
				"groups": {
					...
				}
				...
		```
	*/
	fileprivate func processBook(in data: URLSession.JSONData) throws -> Book
	{
		/* It is critical that groups are preloaded before parsing
		 other data otherwise the groups wont exist when other
		 functions try to look them up by identifier. */
		try preloadGroups(in: data)

		/* Collect top level values. */
		let slug 			= try string(named: "slug", in: data)

		let title 			= try string(named: "title", in: data)
		let description 	= try string(named: "description", in: data)
		let author 			= try string(named: "author", in: data)
		let artist 			= try string(named: "artist", in: data)

		let cover 			= try string(named: "cover", in: data)
		let coverURL		= try linkify(cover: cover)

		/* Parse volumes */
		let volumes 		= try processVolumes(in: data)

		/* Create book */
		let book = BookMutable()

		book.identifier = slug
		book.title = title
		book.author = author
		book.artist = artist
		book.summary = description
		book.cover = coverURL
		book.volumes = volumes

		return try book.copy()
	}

	/**
		Parse object for a list of chapters.

		Example:
		```
		"chapters": {
			"1": {
				"volume": "1",
				"title": "I Want to be Invited to a Movie",
				"folder": "0001_9rr4clfz",
				"groups": {
					...
				}
				...
			"2": {
				"volume": "1",
				"title": "I Want to Play Old Maid",
				"folder": "0002_nih78b9p",
				"groups": {
					...
				}
				...
		```
	*/
	fileprivate func processVolumes(in data: URLSession.JSONData) throws -> Volumes
	{
		let chapters: Structures.Chapters = try object(named: "chapters", in: data)

		/* Chapters are first divided up into a dictionary whose
		 key is the volume number and value is array of chapters
		 in that volume. */
		var chaptersByVolume: [String : Chapters] = [:]

		for (chapter, details) in chapters {
			let volume = try string(named: "volume", in: details)

			let chapter = try processChapter(chapter, in: details)

			/* Am I doing this right? */
			/* In Objective-C, I could store a mutable store and assign
			 append to it by reference. Swift uses structs for arrays
			 so assigning it here isn't modifying the store in the
			 dictionary so I have to reassign it every time. */
			/* Maybe there is a more correct way of doing this that
			 I simply don't know of yet. */
			if var container = chaptersByVolume[volume] {
				container.append(chapter)

				chaptersByVolume[volume] = container
			} else {
				chaptersByVolume[volume] = [chapter]
			}
		}

		/* Take dictionary of volume and chapter pairs and
		 create `Volume` object for each. */
		var volumes: Volumes = []

		for (volume, chapters) in chaptersByVolume {
			let volumeRef = Volume(book: nil, number: volume, chapters: chapters)

			volumes.append(volumeRef)
		}

		return volumes
	}

	/**
		Parse object for a chapter.

		Example:
		```
		"1": {
			"volume": "1",
			"title": "I Want to be Invited to a Movie",
			"folder": "0001_9rr4clfz",
			"groups": {
				...
			}
			...
		```
	*/
	fileprivate func processChapter(_ number: String, in data: Structures.Chapter) throws -> Chapter
	{
		let title =	try string(named: "title", in: data)

		let folder = try string(named: "folder", in: data)

		let releases = try processReleases(in: data, folder: folder)

		return Chapter(volume: nil, number: number, title: title, releases: releases)
	}

	/**
		Parse object for a list of releases.

		Example:
		```
		"groups": {
			"1": [
				"01.jpg",
				"02.jpg",
				"03.jpg",
				"04.jpg",
				"05.jpg",
				...
			"2": [
				"01.jpg",
				"02.jpg",
				"03.jpg",
				"04.jpg",
				"05.jpg",
				...
		```
	*/
	fileprivate func processReleases(in data: URLSession.JSONData, folder: String) throws -> Chapter.Releases
	{
		let releases: Structures.Releases = try object(named: "groups", in: data)

		var releasesOut: Chapter.Releases = []

		for (group, files) in releases {
			let release = try processRelease(files: files, in: folder, by: group)

			releasesOut.append(release)
		}

		return releasesOut
	}

	/**
		Parse object for a release.

		Example:
		```
		"1": [
			"01.jpg",
			"02.jpg",
			"03.jpg",
			"04.jpg",
			"05.jpg",
			...
		```
	*/
	fileprivate func processRelease(files: Structures.Release, in folder: String, by group: String) throws -> Chapter.Release
	{
		guard let groupRef = Group.group(with: group) else {
			os_log("Group '%{public}ld' has a release but isn't identified.",
				   log: Logging.Subsystem.general, type: .fault, group)

			throw Failure.unimplemented
		}

		var pages: [URL] = []

		for file in files {
			let link = try linkify(release: file, in: folder, by: groupRef)

			pages.append(link)
		}

		return Chapter.Release(group: groupRef, pages: pages)
	}

	///
	/// Create URL of the image for a cover.
	///
	/// - Parameter file: Filename of the cover.
	///
	fileprivate func linkify(cover file: String) throws -> URL
	{
		let link = "https://ka.guya.moe\(file)"

		if let url = URL(string: link) {
			return url
		}

		throw Failure.unimplemented
	}

	///
	/// Create URL of the image for a page in a release.
	///
	/// - Parameter file: Filename of the page.
	/// - Parameter folder: Folder in which the page resides.
	/// - Parameter group: The group responsible for the release.
	///
	fileprivate func linkify(release file: String, in folder: String, by group: Group) throws -> URL
	{
		let link = "https://ka.guya.moe/media/manga/\(identifier)/chapters/\(folder)/\(group.identifier)/\(file)"

		if let url = URL(string: link) {
			return url
		}

		throw Failure.unimplemented
	}

	/**
		Parse top level "groups" object.

		Example:

		```
		"groups": {
			"1": "Psylocke Scans",
			"3": "Fans Scans | Jaimini's~Box~",
			"2": "/a/nonymous",
			"4": "NotJag"
		}
		```
	*/
	fileprivate func preloadGroups(in data: URLSession.JSONData) throws
	{
		let groups: Structures.Groups = try object(named: "groups", in: data)

		for (identifier, name) in groups {
			Group.createGroup(identifier: identifier, name: name)

			os_log("Preloading group: (%{public}ld: '%{public}@')",
				   log: Logging.Subsystem.general, type: .debug, identifier, name)
		}
	}

	///
	/// Called if request fails.
	///
	override func taskFailed(with error: URLSession.JSONDataTaskError)
	{
		completionHandler(.failure(.unimplemented))
	}
}

