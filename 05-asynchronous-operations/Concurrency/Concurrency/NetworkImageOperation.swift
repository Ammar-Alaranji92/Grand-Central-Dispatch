import UIKit

class NetworkImageOperation: AsyncOperation {
  typealias ImageOperationCompletion = (((Data?, URLResponse?, Error?)) -> Void)?
  var image: UIImage?

  private let url: URL
  private let completion: ImageOperationCompletion

  init(url: URL, completion: ImageOperationCompletion) {
    self.url = url
    self.completion = completion

    super.init()
  }

  convenience init? (stringURL: String, completion: ImageOperationCompletion) {
    guard let url = URL(string: stringURL) else {return nil }
    self.init(url: url, completion: completion)
  }

  override func main() {
    URLSession.shared.dataTask(with: url, completionHandler: { [weak self] data, response, error in
      guard let self else { return }
      
      defer { state = .finished }

      if let completion {
        completion((data, response, error))
        return
      }

      guard error == nil, let data else { return }
      image = UIImage(data: data)
    })
    .resume()
  }
}
