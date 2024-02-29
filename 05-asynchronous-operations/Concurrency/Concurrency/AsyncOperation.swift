import Foundation

class AsyncOperation: Operation {
  enum State: String {
      case ready, executing, finished

      fileprivate var keyPath: String {
          "is\(rawValue.capitalized)"
      }
  }

  // Create state management
    var state = State.ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath)
            willChangeValue(forKey: state.keyPath)
        }

        didSet {
            didChangeValue(forKey: oldValue.keyPath)
            didChangeValue(forKey: state.keyPath)
        }
    }
  // Override properties
    override var isReady: Bool {
        super.isReady && state == .ready
    }

    override var isExecuting: Bool {
        state == .executing
    }

    override var isFinished: Bool {
        state == .finished
    }

    override var isAsynchronous: Bool {
        true
    }

  // Override start
    // Note: Notice this code doesn’t invoke super.start(). The official documentation (https://apple.co/2YcJvEh) clearly mentions that you must not call super at any time when overriding start.
    // Those two lines probably look backwards to you. They’re really not. Because you’re performing an asynchronous task,
    // the main method is going to almost immediately return, thus you have to manually put the state back to .executing so the operation knows it is still in progress.
    override func start() {
        main()
        state = .executing
    }
}

