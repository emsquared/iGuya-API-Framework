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

extension URLSession
{
	///
	/// Errors thrown by `JSONDataTask(with:completionHandler:)`.
	///
	enum JSONDataTaskError : Error
	{
		///
		/// Address is not formatted correctly.
		///
		/// This error is thrown by `JSONDataTask(with:completionHandler:)`
		/// when it is unable to cast the string address into a URL.
		///
		case addressMalformed

		///
		/// Response is not an HTTP response.
		///
		case responseNotHTTP

		///
		/// Response is not 200 (OK) status code.
		///
		/// - Parameter statusCode: status code of response.
		///
		case responseNotOK(statusCode: Int)

		///
		/// Error originated from `URLSession`
		///
		/// - Parameter error: error returned by `URLSession`
		///
		case sessionError(_ error: Error)

		///
		/// Data received from server is in a form which
		/// is not expected or cannot be decoded.
		///
		case dataMalformed

		///
		/// Data received from server was unable to be decoded
		/// as a JSON payload.
		///
		/// - Parameter: Reason decode failed (if we have one).
		///
		case decodeError(_ error: Error)
	}

	///
	/// Structure of data returned by `JSONDataTask(with:completionHandler:)`.
	///
	typealias JSONData = [String : Any]

	///
	/// Callback handler for `JSONDataTask(with:completionHandler:)`.
	///
	/// - Parameter data: The JSON data retrieved by the task.
	/// - Parameter error: An error which describes why the task failed.
	///
	/// Both parameters will never be `nil` at the same time.
	///
	typealias JSONDataTaskCallback = (_ data: JSONData?, _ error: JSONDataTaskError?) -> Void

	///
	/// Creates and starts a `URLSession` data task with the purpose
	/// of retrieving JSON data from the `url` parameter.
	///
	/// - Parameter url: The URL to be retrieved.
	/// - Parameter completionHandler: The completion handler to call when the task is complete.
	///
	/// Newly-initialized tasks begin in a suspended state, so you
	/// need to call the `resume()` function to start the task.
	///
	func JSONDataTask(with url: URL, completionHandler: @escaping JSONDataTaskCallback) -> URLSessionDataTask
	{
		let session = URLSession.shared

		let sessionTask = session.dataTask(with: url) { (data, response, error) in
			if let error = error {
				completionHandler(nil, .sessionError(error))

				return
			}

			guard let response = response as? HTTPURLResponse else {
				completionHandler(nil, .responseNotHTTP)

				return
			}

			let statusCode = response.statusCode

			guard statusCode == 200 else {
				completionHandler(nil, .responseNotOK(statusCode: statusCode))

				return
			}

			/* data should never be nil because we already checked if error is. */
			/* I have this check because I want to be sane as possible. */
			guard let data = data else {
				completionHandler(nil, .dataMalformed)

				return
			}

			var jsonObject: Any

			do {
				jsonObject = try JSONSerialization.jsonObject(with: data)
			} catch let decodeError {
				completionHandler(nil, .decodeError(decodeError))

				return
			}

			guard let json = jsonObject as? JSONData else {
				completionHandler(nil, .dataMalformed)

				return
			}

			completionHandler(json, nil)
		}

		return sessionTask
	}

	func JSONDataTask(with address: String, completionHandler: @escaping JSONDataTaskCallback) throws -> URLSessionDataTask
	{
		guard let url = URL(string: address) else {
			throw JSONDataTaskError.addressMalformed
		}

		return JSONDataTask(with: url, completionHandler: completionHandler)
	}
}
