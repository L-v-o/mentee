//
//  higher order functions.swift
//
//
//  Created by Danil Mishchenko on 22/07/2026.
//

import Foundation

extension Collection {
    // Map
    
    func map<T>(_ transform: (Element) throws -> T) rethrows -> [T] {
        var result = [T]()
        result.reserveCapacity(count)
        
        for element in self {
            result.append(try transform(element))
        }
        return result
    }
    
    // CompactMap
    
    func compactMap<T>(_ transform: ((Element) throws -> T?)) rethrows -> [T] {
        var result = [T]()
        
        for element in self {
            guard let temp = try transform(element) else {
                continue
            }
            
            result.appends(temp)
        }
    }
    
    // Filter
    
    func filter(_ isIncluded: (Elemnt) throws -> Bool) rethrows -> [Elemnt] {
        var result: [Element] = []
        
        for element in self {
            if try isIncluded(element) {
                result.append(element)
            }
        }
        
        return result
    }
    
    // FlatMap
    
    func flatMap<T>(_ transform: (Element) -> [T]) -> [T] {
        var result: [T] = []
        for element in self {
            result.append(contentsOf: transform(element))
        }
        return result
    }
    
    // Reduce
    
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (Result, Element) throws -> Result) rethrows -> Result {
        var result = initialResult
        for element in self {
            result = try nextPartialResult(result, element)
        }
        return result
    }
}


func topStudents(scores: [(name: String, scores: [Int])], topN: Int) -> [String] {
    let averageScores = scores.map { student -> (name: String, average: Double) in
        let totalScore = Double(student.scores.reduce(0, +))
        let numberOfSubject = Double(student.scores.count)
        let average = totalScore / numberOfSubject // Но тут же не функция высшего порядка или это было допустипо для задания?
        return (name: student.name, average: average)
    }
    
    let sortedStudents = averageScores.sorted { $0.average > $1.average }
    let namesOfTopStudents = sortedStudents.prefix(topN).map { $0.name }
    
    return namesOfTopStudents
}


### В чем отличие map и compactMap?
compactMap - выкидывает из реузльтата nil значения

### Зачем нужен reserveCapacity?
Чтобы заранее зарезервировать память под колекцию и не переалоцировать лишний раз память при добавлении элементов. Т.к дефолтно создается фиксированный буффер под массивы и при заполнение переалоцируются в двое больше по моему.

### Что делают throws и rethrows?
выкидывают ошибки )
throws - говорит о том, что метод может выбросить ошибку
rethrows - говорит о том, что может выбросить ошибку, если кложура выбросит ошибку

### Какие ограничения в дженериках нужны для функции sort?
должны соответствовать Comparable

### Важен ли порядок вызова функций высшего порядка, если их сгруппировать в цепочку вызовов?

да, ведь каждая функция возвращает результат, а следующая вызывается с этим результатом.

