
import Foundation
import iGuyaAPI

func requestBook()
{
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
}

func requestBooks()
{
	var request: Request<Books>?

	request = iGuyaAPI.Gateway.getBooks { (result) in
		switch result {
			case .failure(let error):
				print("Failed: \(error)")
			case .success(let data):
				print("Success: \(data)")
		}

		request = nil
	}

	request?.start()
}

requestBooks()
