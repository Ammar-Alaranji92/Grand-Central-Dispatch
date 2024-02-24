/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

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
let ids = [ 466881, 466910, 466925, 466931, 466978, 467028, 467032, 467042, 467052 ]

let urls = ids.compactMap { URL(string: "\(base)\($0)-jpeg.jpg")}

let dispatchQueue = DispatchQueue.global(qos: .utility)
let dispatchGroup = DispatchGroup()

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
        group.enter()
        downloadImagesWithURLSession(imageURL: imageURL) { image in
            defer { group.leave() }
            if let image {
                images.append(image)
            }
        }
    }
}

//urls.forEach { imageURL in
//    group.enter()
//    downloadImagesWithURLSession(imageURL: imageURL) { image in
//        defer { group.leave() }
//        if let image {
//            images.append(image)
//        }
//    }
//}

// MARK: - Pass the group to the async method, to make shure you wrrap the executiuon with group.enter, and group.leave and avoid side effect of not calling clusures on all cases

//func downloadImagesWithURLSession(on group: DispatchGroup, imageURL: URL, completion: ((UIImage) -> Void)?) {
//    group.enter()
//    URLSession.shared.dataTask(with: imageURL) { data, response, error in
//        defer { group.leave() }
//        guard let data,
//              let image = UIImage(data: data) else {
//            return
//        }
//        completion?(image)
//    }.resume()
//}
//
//urls.forEach { imageURL in
//    downloadImagesWithURLSession(on: group, imageURL: imageURL) { image in
//        images.append(image)
//    }
//}

group.notify(queue: DispatchQueue.main) {
    images

    PlaygroundPage.current.finishExecution()
}
