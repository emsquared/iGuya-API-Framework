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

///
/// `RequestBooks` requests all books one by one (serially).
///
/// If one book fails to download, then that is considered a failure
/// and anything already downloaded and requests pending are discarded.
///
final class RequestBooks : RequestJSON<Books>
{
	override var taskLocation: String?
	{
		return "https://ka.guya.moe/api/get_all_series/"
	}

	///
	/// Books which have been received.
	///
	fileprivate var books: Books = []

	///
	/// Dictionary of book requests mapped to book identifier.
	///
	fileprivate var bookRequests: [String : Request<Book>] = [:]

	///
	/// Dictionary of hashes mapped to book identifier.
	///
	/// This information is used to by caching service.
	///
	fileprivate var bookHashes: [String : Cache.Hash] = [:]

	///
	/// `Structures` defines the layout of objects in the JSON payload.
	///
	fileprivate struct Structures
	{
		typealias Book = [String : Any]
		typealias Books = [String : Book]
	}

	///
	/// Called if one or more requests failed so that internal
	/// state can be cleaned up. Requests are all or not so if
	/// one fails then everything is discarded.
	///
	/// A reset does not remove any books that have already been
	/// added to the cache.
	///
	fileprivate func reset()
	{
		bookRequests.forEach { $1.cancel() }

		bookRequests.removeAll()

		books.removeAll()
	}

	///
	/// Called if request succeeds.
	///
	override func taskCompleted(with data: JSONData) throws
	{
		try processBooks(in: data)
	}

	/**
		Parse object for a list of books.

		Example:
		```
		"Kaguya Wants To Be Confessed To": {
			"author": "Aka Akasaka",
			"artist": "Aka Akasaka",
			"description":
			...
		"Kaguya Wants To Be Confessed To Official Doujin": {
			"author": "Sakayama Shinta",
			"artist": "Sakayama Shinta",
			"description"
			...
		```
	*/
	fileprivate func processBooks(in data: JSONData) throws
	{
		for (_, details) in data {
			guard let book = details as? Structures.Book else {
				throw Failure.dataMalformed
			}

			try processBook(book)
		}

		startNextBookRequest()
	}

	fileprivate func processBook(_ book: Structures.Book) throws
	{
		let identifier = try string(named: "slug", in: book)

		let hash: Cache.Hash = try object(named: "series_data_hash", in: book)

		/* Return book from the cache if it exists. */
		if let cachedBook = Cache.shared.book(with: hash) {
			os_log("Book '%{public}@' found in cache with hash '%{public}ld'.",
				log: Logging.Subsystem.general, type: .debug, identifier, hash)

			bookRequestFinalize(for: cachedBook, addToCache: false)

			return
		} else {
			/* If this hash has no cached copy, then we have never
			 seen it before, or it is a new version of the book. */
			/* Remove any old copies of the book from the cache. */

			Cache.shared.remove(book: identifier)
		}

		try createBookRequest(for: identifier, with: hash)
	}

	fileprivate func createBookRequest(for book: String, with hash: Cache.Hash) throws
	{
		guard let request = RequestBook(book, { [weak self] (result) in
			self?.bookRequestFinished(with: result)
		}) else {
			os_log("Failed to create request for book '%@'",
				   log: Logging.Subsystem.general, type: .fault, book)

			throw Failure.otherError()
		}

		bookRequests[book] = request
		bookHashes[book] = hash
	}

	///
	/// Start next request for books or finalize the request
	/// if there are no more requests to be made.
	///
	/// Requests are processed serially to avoid burden of
	/// setting up a queue to prevent race conditions.
	///
	fileprivate func startNextBookRequest()
	{
		if let (_, request) = bookRequests.first {
			request.start()

			return
		}

		finalize(with: books)
	}

	///
	/// Callback handler for book requests.
	///
	fileprivate func bookRequestFinished(with result: Request<Book>.CompletionResult)
	{
		switch (result) {
			case .failure(let error):
				bookRequestFailed(with: error)
			case .success(let book):
				bookRequestSucceeded(for: book)

				startNextBookRequest()
		}
	}

	///
	/// Called when a book request fails.
	///
	fileprivate func bookRequestFailed(with error: Failure)
	{
		reset() // Reset internal state

		finalize(with: error)
	}

	///
	/// Called when a book request succeeds.
	///
	fileprivate func bookRequestSucceeded(for book: Book)
	{
		bookRequests.removeValue(forKey: book.identifier)

		bookRequestFinalize(for: book)
	}

	///
	/// Called to finalize a book request.
	///
	/// This function may be called from outside a `Request` object
	/// because `processBook()` will call it if a cached book is found.
	///
	/// - Parameter book: The book that was requested.
	/// - Parameter addToCache: `true` to add book to cache. `false` otherwise.
	///
	fileprivate func bookRequestFinalize(for book: Book, addToCache: Bool = true)
	{
		books.append(book)

		if let hash = bookHashes.removeValue(forKey: book.identifier) {
			if (addToCache) {
				Cache.shared.add(book: book, with: hash)
			}
		}
	}
}
