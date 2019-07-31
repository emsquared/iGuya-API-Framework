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

///
/// `Volume` represents a specific volume in `book`
///
final public class Volume : Comparable, CustomStringConvertible
{
	///
	/// The book the volume belongs to.
	///
	/// This is a weak reference.
	///
	public fileprivate(set) weak var book: Book?

	///
	/// The volume number.
	///
	public fileprivate(set) var number: String

	///
	/// Chapters the volume contains.
	///
	public fileprivate(set) var chapters: Chapters {
		willSet (chapters) {
			chapters.forEach { $0.assignVolume(self) }
		}
	}

	///
	/// Create a new instance of `Volume`.
	///
	init (book: Book?, number: String, chapters: Chapters)
	{
		self.book = book
		self.number = number
		self.chapters = chapters.sorted(by: <)
	}

	///
	/// `Volume` objects are created before `Book` objects.
	/// `assignBook()` assigns a `Book` object once it
	/// becomes available.
	///
	/// This function only assigns the book if none is set.
	///
	/// This function is automatically called by the `willSet`
	/// handler for the `volumes` property in `Book`.
	/// There is no need to call it directly.
	///
	/// - Parameter book: The book the volume belongs to.
	///
	func assignBook(_ book: Book)
	{
		if self.book == nil {
			self.book = book
		}
	}

	///
	/// String representation of `Volume`.
	///
	public var description: String
	{
		return """
		Volume(
			number: '\(number)',
			chapters:
				\(chapters)
		)
		"""
	}

	///
	/// Sort by `number`.
	///
	public static func < (lhs: Volume, rhs: Volume) -> Bool
	{
		let number1 = lhs.number
		let number2 = rhs.number

		return number1.compareAsDouble(number2, <)
	}

	///
	/// Equal if both are the same reference.
	///
	public static func == (lhs: Volume, rhs: Volume) -> Bool
	{
		return lhs === rhs
	}
}

///
/// `Volumes` is a collection of `Volume`.
///
public typealias Volumes = [Volume]
