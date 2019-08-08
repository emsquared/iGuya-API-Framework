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
/// `RequestJSON` is a specialized generic subclass of `Request` which is
/// capable of making calls to the API for subclasses which expect JSON.
///
/// - SeeAlso: Request
///
class RequestJSON<RequestType>: Request<RequestType>
{
	///
	/// Structure of data returned by `RequestJSON`.
	///
	typealias JSONData = [String: Any]

	///
	/// Called if decoding the JSON data succeeds.
	///
	func taskCompleted(with data: JSONData) throws
	{

	}

	///
	/// Called if the request succeeds.
	///
	override func taskCompleted(with data: Data) throws
	{
		var jsonObject: Any

		do {
			jsonObject = try JSONSerialization.jsonObject(with: data)
		} catch let decodeError {
			os_log("Decode failed with error: '%{public}@'.",
				   log: Logging.Subsystem.general, type: .error, decodeError.localizedDescription)

			finalize(with: .otherError(decodeError))

			return
		}

		guard let json = jsonObject as? JSONData else {
			os_log("Decoding failed because data is malformed.",
				   log: Logging.Subsystem.general, type: .error)

			finalize(with: .dataMalformed)

			return
		}

		try taskCompleted(with: json)
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
	func object<T>(named: String, in data: JSONData) throws -> T
	{
		if let value = data[named] as? T {
			return value
		}

		os_log("'%{public}@' is missing or is malformed.",
			   log: Logging.Subsystem.general, type: .fault, named)

		throw Failure.dataMalformed
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
	func string(named: String, in data: JSONData) throws -> String
	{
		return try object(named: named, in: data)
	}
}
