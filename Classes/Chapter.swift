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
final public class Chapter {
	///
	/// The volume the chapter belongs to.
	///
	public fileprivate(set) weak var volume: Volume?

	///
	/// The chapter number.
	///
	public fileprivate(set) var number: Int

	///
	/// A chapter can have multiple releases.
	/// Such as one from a JP -> KR -> EN group.
	/// And one from a JP -> EN group.
	/// `Release` represents a specific release.
	///
	public struct Release {
		///
		/// The group that created the release.
		///
		public let group: Group

		///
		/// List of pages, in order, for the release.
		///
		public let pages: [URL]
	}

	///
	/// `Releases` is a collection of `Release`.
	///
	public typealias Releases = [Release]

	///
	/// All releases for the chapter.
	///
	public fileprivate(set) var releases: Releases

	///
	/// Create a new instance of `Volume`.
	///
	init (volume: Volume?, number: Int, releases: Releases)
	{
		self.volume = volume
		self.number = number
		self.releases = releases
	}
}

///
/// `Chapters` is a collection of `Chapter`.
///
public typealias Chapters = [Chapter]
