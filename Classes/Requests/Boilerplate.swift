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
/// Errors thrown by `Request`.
///
public enum RequestError
{
	///
	/// Placeholder error until others are added.
	///
	case unimplemented
}

///
/// `Request` acts as host of sessions tasks for performing API requests.
///
/// Each API request is divided into an extension of `Request` with their
/// own convenience initializer.
///
public class Request
{
	///
	/// Locations for API gateways.
	///
	/// Each type of request extends this class to add its own location.
	///
	final class Locations
	{
		static let base = "https://guya.moe/api"
	}

	fileprivate var task: URLSessionDataTask?

	init (with task: URLSessionDataTask)
	{
		self.task = task
	}

	/* Task is discarded when `Request` is no longer in use. */
	deinit
	{
		task = nil

		print("Request discarded")
	}

	///
	/// Start the request.
	///
	/// Newly-initialized requests begin in a suspended state, so you
	/// need to call this function to start the request.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult public func start() -> Bool
	{
		guard let task = task else {
			return false
		}

		guard task.state == .suspended else {
			print("Task is not suspended")

			return false
		}

		task.resume()

		print("Started task: \(task)")

		return true
	}

	///
	/// Cancel the request.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult public func cancel() -> Bool
	{
		guard let task = task else {
			return false
		}

		guard task.state == .running else {
			print("Task is not running")

			return false
		}

		task.cancel()

		print("Cancelled task: \(task)")

		return true
	}
}
