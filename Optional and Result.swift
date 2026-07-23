//
//  Optional and Result.swift
//  
//
//  Created by Danil Mishchenko on 23/07/2026.
//

enum MyOptional<Wrapped>: ExpressibleByNilLiteral {
    case none
    case some(Wrapped)
    
    init(nilLiteral: ()) {
        self = .none
    }
}


// MARK: - Как реализовать isEmptyOrNil?

extension MyOptional where Wrapped: Collection {
    var isEmptyOrNil: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }
}

// MARK: - Как добавить свой force unwrap?

extension MyOptional {
    func forceUnwrap() -> Wrapped {
        switch self {
        case .some(let value):
            return value
        case .none:
            fatalError("Unexpectedly found nil while unwrapping an Optional value")
        }
    }
}

// MARK: - Equatable для Result

extension Result where Success: Equatable, Failure: Equatable {
    public static func == (lhs: Result<Success, Failure>, rhs: Result<Success, Failure>) -> Bool {
        switch (lhs, rhs) {
        case (.success(let lValue), .success(let rValue)):
            return lValue == rValue
        case (.failure(let lError), .failure(let rError)):
            return lError == rError
        default:
            return false
        }
    }
}

// MARK: - ?? - nil coalescing operator

extension MyOptional {
    static func ??(lhs: MyOptional<Wrapped>, rhs: @autoclosure () throws -> Wrapped) rethrows -> Wrapped {
        switch lhs {
        case .some(let value):
            return value
        case .none:
            return try rhs()
        }
    }
}
