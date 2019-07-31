
import Foundation
import iGuyaAPI

var request: Request<Book>?

request = iGuyaAPI.Gateway.getBook("Kaguya-Wants-To-Be-Confessed-To", { (result) in
	switch result {
		case .failure(let error):
			print("Failed: \(error)")
		case .success(let data):
			print("Success: \(data)")
	}

	request = nil
})

request?.start()
