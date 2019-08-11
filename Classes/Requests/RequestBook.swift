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

final class RequestBook: RequestJSON<Book>
{
	override var taskLocation: String?
	{
		return "https://ka.guya.moe/api/series/\(identifier)/"
	}

	fileprivate(set) var identifier: String

	init? (_ named: String, _ completionHandler: @escaping CompletionHandler)
	{
		guard named.isBookIdentifier else {
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
		typealias Groups = [String: String]
		typealias Chapter = [String: Any]
		typealias Chapters = [String: Chapter]
		typealias Release = [String]
		typealias Releases = [String: Release]
	}

	///
	/// Called if request succeeds.
	///
	override func taskCompleted(with data: JSONData) throws
	{
		let book = try processBook(in: data)

		finalize(with: book)
	}

	/**
		Parse object for a book.

		Example:
		```
		{
			"slug": "Kaguya-Wants-To-Be-Confessed-To",
			"title": "Kaguya Wants To Be Confessed To",
			"description": ...
			"author": "Aka Akasaka",
			"artist": "Aka Akasaka",
			...
		```
	*/
	fileprivate func processBook(in data: JSONData) throws -> Book
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

		guard let coverURL = Linkify.cover(with: cover) else {
			throw Failure.dataMalformed
		}

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
	fileprivate func processVolumes(in data: JSONData) throws -> Volumes
	{
		let chapters: Structures.Chapters = try object(named: "chapters", in: data)

		/* Chapters are first divided up into a dictionary whose
		 key is the volume number and value is array of chapters
		 in that volume. */
		var chaptersByVolume: [Int: Chapters] = [:]

		for (chapter, details) in chapters {
			guard let chapterNumber = Double(chapter) else {
				throw Failure.dataMalformed
			}

			let volume = try string(named: "volume", in: details)

			guard let volumeNumber = Int(volume) else {
				throw Failure.dataMalformed
			}

			let chapter = try processChapter(chapterNumber, in: details)

			/* Am I doing this right? */
			/* In Objective-C, I could store a mutable store and assign
			 append to it by reference. Swift uses structs for arrays
			 so assigning it here isn't modifying the store in the
			 dictionary so I have to reassign it every time. */
			/* Maybe there is a more correct way of doing this that
			 I simply don't know of yet. */
			if var container = chaptersByVolume[volumeNumber] {
				container.append(chapter)

				chaptersByVolume[volumeNumber] = container
			} else {
				chaptersByVolume[volumeNumber] = [chapter]
			}
		}

		/* Take dictionary of volume and chapter pairs and
		 create `Volume` object for each. */
		var volumes: Volumes = []

		for (volume, chapters) in chaptersByVolume {
			let volumeRef = Volume(number: volume, chapters: chapters)

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
	fileprivate func processChapter(_ number: Double, in data: Structures.Chapter) throws -> Chapter
	{
		let title =	try string(named: "title", in: data)

		let folder = try string(named: "folder", in: data)

		let releases = try processReleases(in: data)

		return Chapter(number: number, title: title, releases: releases, folder: folder)
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
	fileprivate func processReleases(in data: JSONData) throws -> Chapter.Releases
	{
		let releases: Structures.Releases = try object(named: "groups", in: data)

		var releasesOut: Chapter.Releases = []

		for (group, files) in releases {
			let release = try processRelease(files: files, by: group)

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
	fileprivate func processRelease(files: Structures.Release, by group: String) throws -> Chapter.Release
	{
		guard let groupRef = Group.group(with: group) else {
			os_log("Group '%{public}@' has a release but isn't identified.",
				   log: Logging.Subsystem.general, type: .error, group)

			throw Failure.dataMalformed
		}

		typealias Page = Chapter.Release.Page

		var pages: [Page] = []

		for file in files {
			let number = (pages.count + 1)

			let page = Page(number: number, file: file)

			pages.append(page)
		}

		return Chapter.Release(group: groupRef, pages: pages)
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
	fileprivate func preloadGroups(in data: JSONData) throws
	{
		let groups: Structures.Groups = try object(named: "groups", in: data)

		for (identifier, name) in groups {
			Group.createGroup(identifier: identifier, name: name)
		}
	}
}
