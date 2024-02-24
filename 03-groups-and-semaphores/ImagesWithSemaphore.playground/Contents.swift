import UIKit

import PlaygroundSupport

/*:
 Tell the playground to continue running, even after it thinks execution has ended.
 You need to do this when working with background tasks.
 */

PlaygroundPage.current.needsIndefiniteExecution = true

let group = DispatchGroup()
let queue = DispatchQueue.global(qos: .userInitiated)

let base = "https://wolverine.raywenderlich.com/books/con/image-from-rawpixel-id-"
let ids = [ 466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052, 466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052 ]

let urls = ids.compactMap { URL(string: "\(base)\($0)-jpeg.jpg")}

let dispatchQueue = DispatchQueue.global(qos: .utility)
let dispatchGroup = DispatchGroup()
let semaphore = DispatchSemaphore(value: 2)

var images: [UIImage] = []

func downloadImagesWithURLSession(imageURL: URL, completion: ((UIImage?) -> Void)?) {
    URLSession.shared.dataTask(with: imageURL) { data, response, error in
        guard let data,
              let image = UIImage(data: data) else {
            completion?(nil)
            return
        }
        completion?(image)
    }.resume()
}

// MARK: - You should link the queue with the group to let it know that it should wait for the internal sub tasks to finish before it finishs its work
queue.async(group: group) {
    urls.forEach { imageURL in
        print("Downloading image \(imageURL.absoluteString)")
        semaphore.wait()
        group.enter()
        downloadImagesWithURLSession(imageURL: imageURL) { image in
            defer {
                print("Downloading finished for image \(imageURL.absoluteString)")
                group.leave()
                semaphore.signal()
            }
            if let image {
                images.append(image)
            }
        }
    }
}

//urls.forEach { imageURL in
//    print("Downloading image \(imageURL.absoluteString)")
//    semaphore.wait()
//    group.enter()
//    downloadImagesWithURLSession(imageURL: imageURL) { image in
//        defer { 
//            print("Downloading finished for image \(imageURL.absoluteString)")
//            group.leave()
//            semaphore.signal()
//        }
//        if let image {
//            images.append(image)
//        }
//    }
//}

// MARK: - Pass the group to the async method, to make shure you wrrap the executiuon with group.enter, and group.leave and avoid side effect of not calling clusures on all cases

func downloadImagesWithURLSession(on group: DispatchGroup, imageURL: URL, completion: ((UIImage) -> Void)?) {
    semaphore.wait()
    group.enter()
    print("Downloading image \(imageURL.absoluteString)")
    URLSession.shared.dataTask(with: imageURL) { data, response, error in
        defer {
            print("Downloading finished for image \(imageURL.absoluteString)")
            group.leave()
            semaphore.signal()
        }
        guard let data,
              let image = UIImage(data: data) else {
            return
        }
        completion?(image)
    }.resume()
}

//urls.forEach { imageURL in
//    downloadImagesWithURLSession(on: group, imageURL: imageURL) { image in
//        images.append(image)
//    }
//}

group.notify(queue: DispatchQueue.main) {
    images

    PlaygroundPage.current.finishExecution()
}
