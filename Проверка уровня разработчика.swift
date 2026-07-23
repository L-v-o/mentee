//
//  Проверка уровня разработчика.swift
//
//
//  Created by Danil Mishchenko on 22/07/2026.
//

struct AwesomeData: Hashable, Comparable {
    let id: String
    let awesomeField: Int
    let date: Date
    
    static func < (lhs: AwesomeData, rhs: AwesomeData) {
        lhs.date < rhs.date
    }
}

enum AwesomeError: Error {
    case badRequest(Error)
    case unknown
}

protocol AwesomeService {
    func getAwesomeData(completion: @escaping (Result<[AwesomeData], AwesomeError>) -> Void)
}

final class AwesomeServiceImpl: AwesomeService {
    
    private let api: Api
    
    init(api: Api) {
        self.api = api
    }
    
    func getAwesomeData(completion: @escaping (Result<[AwesomeData], AwesomeError>) -> Void) {
        api.get(.awesomeData) { data, error in
            if let error {
                completion(.failure(error))
            } else if let data {
                completion(.success(data))
            } else {
                completion(.failure(.unknown))
            }
        }
    }
}

final class AwesomeViewController: UIViewController {
    
    private let service: AwesomeService
    private var awesomeSet = Set<AwesomeData>()
    private var timer: Timer?
    private let button = UIButton()
    private let queue = DispatchQueue(label: "synchronize", attributes: .concurrent)
    
    init(service: AwesomeService) {
        self.service = service
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(
            timeInterval: 1,
            target: self,
            selector: #selector(runTimedCode)
            userInfo: nil,
            repeats: true
        )
        
        button.addTarget(
            self,
            action: #selector(buttonTap),
            for: .touchUpInside
        )
    }
    
    @objc
    private func runTimedCode() {
        loadData()
    }
    
    private func loadData() {
        service.getAwesomeData { [weak self] result in
            switch result {
            case .success(let data):
                self?.queue.async(flags: .barrier) {
                    data.forEach {
                        awesomeSet.insert($0)
                    }
                }
            case .failure:
                break
            }
        }
    }
    
    @objc
    private func buttonTap() {
        queue.sync {
            let min = awesomeSet.min()
            print(min)
        }
    }
}


// MARK: - Async/Await variant

actor AwesomeStore {
    private var awesomeSet = Set<AwesomeData>()
    
    func insert(_ items: [AwesomeType]) {
        items.forEach { awesomeSet.insert($0) }
    }
}

private func loadData() async {
    let data = try await service.getAwesomeData()
    await awesomeStore.insert(data)
}
    

