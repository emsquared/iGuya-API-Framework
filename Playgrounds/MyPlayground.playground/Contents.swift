
import Foundation
import iGuyaAPI

var request: Request?

request = iGuyaAPI.Request(getAllGroups: { (result) in
	switch result {
		case .failure(let error):
			print("Failed: \(error)")
		case .success(let data):
			for group in data {
				print("ID: \(group.identifier); Name: \(group.name)")
			}
	}

	request = nil
})

request?.start()
