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
/// `Request` acts as a generic base class for specialized subclasses.
///
/// `Request` is a generic class which takes one type. That type is the result type.
/// For example: A subclass of `Request` that returns an array of `Group` objects
/// is specialized as `Request<Groups>`
///
public class Request<ResultType>
{
	///
	/// Errors thrown by `Request`.
	///
	public enum Failure : Error
	{
		///
		/// Data received from endpoint is in a form which
		/// is not expected or cannot be handled.
		///
		case dataMalformed

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
		/// Error received from a lower level API which
		/// is being rethrown as a wrapped by `Failure`.
		///
		case otherError(_ error: Error)
	}

	///
	/// Completion handler that is called when the request finishes.
	///
	/// - Parameter data: The result of request.
	/// - Parameter error: An error which describes why the request failed.
	///
	/// Both parameters will never be `nil` at the same time.
	///
	public typealias CompletionHandler = (Result<ResultType, Failure>) -> Void

	fileprivate var completionHandler: CompletionHandler

	///
	/// Designated initializer for `Request`.
	///
	init (with completionHandler: @escaping CompletionHandler)
	{
		self.completionHandler = completionHandler
	}

	///
	/// Task that the request hosts.
	///
	fileprivate var task: URLSessionDataTask?

	///
	/// The remote address (URL) of the endpoint for the request.
	///
	/// Subclasses of `Request` do not currently require arguments
	/// to be passed to the location. If a time comes that is needed,
	/// then we could add an additional property for returning a
	/// formatted `NSURLRequest`.
	///
	var taskLocation: String?
	{
		return nil
	}

	/* Task is discarded when `Request` is no longer in use. */
	deinit
	{
		task = nil
	}

	///
	/// Start the request.
	///
	/// Newly-initialized requests begin in a suspended state, so you
	/// need to call this function to start the request.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult public final func start() -> Bool
	{
		var taskRef = task

		if (taskRef == nil) {
			taskRef = constructTask()
		}

		/* Another nil check is not needed because
		 the state will never be suspended if we
		 have a nil task returned by constructor. */
		guard taskRef?.state == .suspended else {
			return false
		}

		taskRef?.resume()

		return true
	}

	///
	/// Cancel the request.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult public final func cancel() -> Bool
	{
		let taskRef = task

		guard taskRef?.state == .running else {
			return false
		}

		taskRef?.cancel()

		return true
	}

	///
	/// Factory for the request task.
	///
	fileprivate func constructTask() -> URLSessionDataTask?
	{
		guard 	let location = taskLocation,
				let locationURL = URL(string: location) else {
			return nil
		}

		let session = URLSession.shared

		let sessionTask = session.dataTask(with: locationURL) { [weak self] (data, response, error) in
			if let error = error {
				self?.finalize(with: .sessionError(error))

				return
			}

			guard let response = response as? HTTPURLResponse else {
				self?.finalize(with: .responseNotHTTP)

				return
			}

			let statusCode = response.statusCode

			guard statusCode == 200 else {
				self?.finalize(with: .responseNotOK(statusCode: statusCode))

				return
			}

			/* data should never be nil because we already checked if error is. */
			/* I have this check because I want to be sane as possible. */
			guard let data = data else {
				self?.finalize(with: .dataMalformed)

				return
			}

			self?.taskCompleted(with: data)
		} // sessionTask

		return sessionTask
	}

	///
	/// Called if the request fails.
	///
	func taskFailed(with error: Error)
	{
		completionHandler(.failure(.otherError(error)))
	}

	///
	/// Called if the request succeeds.
	///
	func taskCompleted(with data: Data)
	{

	}

	///
	/// Exit for the request when error handling is finished.
	///
	final func finalize(with error: Failure)
	{
		os_log("Request failed with error: %{public}@",
			   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

		completionHandler(.failure(error))
	}

	///
	/// Exit for the request when parsing of data is finished.
	///
	final func finalize(with result: ResultType)
	{
		completionHandler(.success(result))
	}
}
