
import Foundation
import iGuyaAPI

var request: Request?

request = iGuyaAPI.Request(getAllGroups: { (data, error) in
	for group in data! {
		print("ID: \(group.identifier); Name: \(group.name)")
	}

	request = nil
})

request?.start()
