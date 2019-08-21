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

public extension Book
{
	///
	/// Format to write contents of `Book` as.
	///
	enum WriteFormat
	{
		///
		/// JSON
		///
		case json

		///
		/// Binary property list
		///
		case propertyList
	}

	///
	/// Write contents of `Book` to `url` as `format`.
	///
	/// - Parameter url: Location to write data to.
	/// - Parameter format: Format to write data as.
	/// 					Defaults to binary property list.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	func writeTo(url: URL, as format: WriteFormat = .propertyList) -> Bool
	{
		let data: Data?

		switch (format) {
			case .json:
				data = jsonData
			case .propertyList:
				data = propertyListData
		}

		if (data == nil) {
			return false
		}

		do {
			try data!.write(to: url)

			return true
		} catch let error {
			os_log("Writing failed with error: '%{public}@'.",
				   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

			return false
		}
	}

	///
	/// Write contents of `Book` to Desktop folder.
	///
	/// - Warning: This function is for debug purposes. There is
	/// no gurantee of its behavior or whether it will always exist.
	///
	@discardableResult
	func writeToDebugLocation(as format: WriteFormat = .propertyList) -> Bool
	{
		let debugLocation = URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop/book.txt")

		return writeTo(url: debugLocation, as: format)
	}

	///
	/// JSON representation of `Book`.
	///
	var json: String?
	{
		guard let data = jsonData else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	///
	/// JSON representation of `Book`.
	///
	var jsonData: Data?
	{
		do {
			let encoder = JSONEncoder()

			let data = try encoder.encode(self)

			return data
		} catch let error {
			os_log("Encoding failed with error: '%{public}@'.",
				   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

			return nil
		}
	}

	///
	/// XML property list representation of `Book`.
	///
	var propertyList: String?
	{
		guard let data = propertyListData(as: .xml) else {
			return nil
		}

		return String(data: data, encoding: .utf8)
	}

	///
	/// Binary property list representation of `Book`.
	///
	var propertyListData: Data?
	{
		return propertyListData(as: .binary)
	}

	///
	/// Property list representation of `Book` as `format`.
	///
	fileprivate func propertyListData(as format: PropertyListSerialization.PropertyListFormat) -> Data?
	{
		do {
			let encoder = PropertyListEncoder()
			encoder.outputFormat = format

			let data = try encoder.encode(self)

			return data
		} catch let error {
			os_log("Encoding failed with error: '%{public}@'.",
				   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

			return nil
		}
	}
}
