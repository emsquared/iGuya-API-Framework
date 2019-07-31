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
class RequestJSON<RequestType> : Request<RequestType>
{
	///
	/// Task that the request hosts.
	///
	fileprivate var task: URLSessionDataTask?

	///
	/// The remote address (URL) of the endpoint for the request.
	///
	/// Subclasses of `RequestJSON` do not currently require arguments
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

	@discardableResult public override func start() -> Bool
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

	@discardableResult public override func cancel() -> Bool
	{
		let taskRef = task

		guard taskRef?.state == .running else {
			return false
		}

		taskRef?.cancel()

		return true
	}

	///
	/// Called if request fails.
	///
	func taskFailed(with error: URLSession.JSONDataTaskError)
	{

	}

	///
	/// Called if request succeeds.
	///
	func taskCompleted(with data: URLSession.JSONData)
	{

	}

	///
	/// Factory for request task.
	///
	fileprivate func constructTask() -> URLSessionDataTask?
	{
		guard let location = taskLocation else {
			return nil
		}

		let taskd = try? URLSession.shared.JSONDataTask(with: location) { [weak self] (result) in
			switch result {
				case .failure(let error):
					os_log("Request failed with error: %{public}@",
						   log: Logging.Subsystem.general, type: .error, error.localizedDescription)

					self?.taskFailed(with: error)
				case .success(let data):
					self?.taskCompleted(with: data)
			}
		}

		return taskd
	}
}
