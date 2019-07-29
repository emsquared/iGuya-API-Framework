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

public extension Request
{
	convenience init (getAllGroups completionHandler: @escaping GetAllGroups.CompletionHandler)
	{
		let taskd = GetAllGroups.task(with: completionHandler)

		self.init(with: taskd)
	}

	class GetAllGroups
	{
	}
}

public extension Request.GetAllGroups
{
	typealias CompletionHandler = (Result<Groups, Request.Failure>) -> Void

	fileprivate static func task(with completionHandler: @escaping CompletionHandler) -> URLSessionDataTask
	{
		let location = Request.Locations.getAllGroups

		/* This may throw because the location that is supplied does not
		 produce a URL object. We control the address supplied to it which
		 means it is safe for us to force the error aside. */
		let taskd = try! URLSession.shared.JSONDataTask(with: location) { (result) in
			switch result {
				case .failure(let error):
					taskFailed(with: error, completionHandler: completionHandler)
				case .success(let data):
					taskCompleted(with: data, completionHandler: completionHandler)
			}
		}

		return taskd
	}

	fileprivate static func taskFailed(with error: URLSession.JSONDataTaskError,
									  completionHandler: CompletionHandler)
	{
		print("Error received: \(error)")

		completionHandler(.failure(.unimplemented))

		return
	}

	fileprivate static func taskCompleted(with data: URLSession.JSONData,
										  completionHandler: CompletionHandler)
	{
		var groups: Groups = []

		for (key, value) in data {
			guard let identifier = Int(key) else {
				print("Failed to cast group identifier into integer.")

				completionHandler(.failure(.unimplemented))

				continue
			}

			guard let name = value as? String else {
				print("Failed to cast group name into string.")

				completionHandler(.failure(.unimplemented))

				continue
			}

			let group = Group(identifier: identifier, name: name)

			groups.append(group)
		}

		completionHandler(.success(groups))
	}
}

extension Request.Locations
{
	static let getAllGroups = "\(base)/get_all_groups"
}
