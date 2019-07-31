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
/// `Request` acts as a generic base class for specialized subclasses.
///
/// `Request` is a generic class which takes one type. That type is the result type.
/// For example: A subclass of `Request` that returns an array of `Group` objects
/// is specialized as `Request<Groups>`
///
/// Creating an instance of `Request` outside of a specialized subclass will create a
/// request that does absolutely nothing.
///
public class Request<ResultType>
{
	///
	/// Errors thrown by `Request`.
	///
	/// Subclasses may extend this enum.
	/// See the documentation for those.
	///
	public enum Failure : Error
	{
		case unimplemented // placeholder
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

	private(set) var completionHandler: CompletionHandler

	///
	/// Designated initializer for `Request`.
	///
	init (with completionHandler: @escaping CompletionHandler)
	{
		self.completionHandler = completionHandler
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
		return false
	}

	///
	/// Cancel the request.
	///
	/// - Returns: `true` on success. `false` otherwise.
	///
	@discardableResult public func cancel() -> Bool
	{
		return false
	}
}
