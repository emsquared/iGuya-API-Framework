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

import Dispatch

///
/// `Cache` maintains a copy of `Book` objects in memory
/// and/or on disk to optimize loading.
///
/// The API associates a unique integer with each book
/// that changes when the contents of the book do.
///
/// `Cache` uses this unique integer (the "hash") as
/// the means to uniquely identify a specific version
/// of a book.
///
class Cache
{
	///
	/// Integer which is used to uniquely identify
	/// a specific version of a book.
	///
	typealias Hash = Int

	///
	/// Dictionary of books mapped to hashes.
	///
	fileprivate var cache: [Hash : Book] = [:]

	///
	/// Dispatch queue to perform access to `cache` on to
	/// avoid race conditions.
	///
	fileprivate let cacheQueue = DispatchQueue(label: "CacheQueue")

	///
	/// Shared instance of the cache.
	///
	static var shared = Cache()

	///
	/// Add `book` to the cache and associate it with `hash`.
	///
	/// - Parameter book: A book to add to the cache.
	/// - Parameter hash: The hash to associate the book with.
	///
	func add(book: Book, with hash: Hash)
	{
		cacheQueue.sync {
			cache[hash] = book
		}
	}

	///
	/// Remove book from cache that is associated to `hash`.
	///
	/// - Parameter hash: The hash associated with the book.
	///
	func remove(hash: Hash)
	{
		cacheQueue.sync {
			_ = cache.removeValue(forKey: hash)
		}
	}

	///
	/// Remove `book` from the cache.
	///
	/// - Parameter book: A book to remove from the cache.
	///
	func remove(book: Book)
	{
		cacheQueue.sync {
			if let key = cache.firstIndex(where: { $1 == book }) {
				cache.remove(at: key)
			}
		}
	}

	///
	/// Remove `book` from the cache.
	///
	/// - Parameter identifier: Identifier of a book to remove from the cache.
	///
	func remove(book identifier: String)
	{
		cacheQueue.sync {
			if let key = cache.firstIndex(where: { $1.identifier == identifier }) {
				cache.remove(at: key)
			}
		}
	}

	///
	/// Return book from the cache if it exists for `hash`.
	///
	/// - Parameter hash: The hash associated with the book.
	///
	func book(with hash: Hash) -> Book?
	{
		var book: Book?

		cacheQueue.sync {
			book = cache[hash]
		}

		return book
	}
}

