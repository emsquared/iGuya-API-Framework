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

final class RequestBook : RequestJSON<Book>
{
	override var taskLocation: String?
	{
		return "https://guya.moe/api/series/\(identifier)/"
	}

	fileprivate(set) var identifier: String

	init? (_ named: String, _ completionHandler: @escaping CompletionHandler)
	{
		guard named.matches(#"^([\w-]+)$"#) else {
			return nil
		}

		self.identifier = named

		super.init(with: completionHandler)
	}

	struct Structures
	{
		typealias Groups = [String : String]
	}

	override func taskCompleted(with data: URLSession.JSONData)
	{
		guard let groups = data["groups"] as? Structures.Groups, preloadGroups(groups) else {
			os_log("'groups' structure is missing or incorrect format.",
				   log: Logging.Subsystem.general, type: .fault)

			completionHandler(.failure(.unimplemented))

			return
		}








///		completionHandler(.success(...))
	}

	fileprivate func preloadGroups(_ groups: Structures.Groups) -> Bool
	{
		for (key, name) in groups {
			guard let identifier = Int(key) else {
				os_log("Failed to cast identifier '%{public}@' for group '%{public}@' into integer.",
					   log: Logging.Subsystem.general, type: .fault, key, name)

				return false
			}

			Group.createGroup(identifier: identifier, name: name)

			os_log("Preloading group: (%{public}ld: '%{public}@')",
				   log: Logging.Subsystem.general, type: .debug, identifier, name)
		}

		return true
	}

	override func taskFailed(with error: URLSession.JSONDataTaskError)
	{
		completionHandler(.failure(.unimplemented))
	}
}

