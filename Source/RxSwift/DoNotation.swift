//
//  DoNotation.swift
//  RxSwiftExt
//
//  Created by sudo.park on 2022/03/30.
//  Copyright © 2022 RxSwiftCommunity. All rights reserved.
//

import RxSwift

#if swift(>=5.5.2) && canImport(_Concurrency)
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension ObservableType {
    
    func flatMap<T>(do expression: @escaping (Element) async throws -> T?) -> Observable<T> {
        
        let runExpression: (Element) throws -> Observable<T> = { element in
            
            return Observable.create { observer in
                
                
                let task = Task {
                    do {
                        if let result = try await expression(element) {
                            observer.onNext(result)
                        }
                        observer.onCompleted()
                            
                    } catch {
                        observer.onError(error)
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}
#endif


#if swift(>=5.5.2) && canImport(_Concurrency) && !os(Linux)
@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension PrimitiveSequenceType where Trait == SingleTrait {
    
    func flatMap<T>(do expression: @escaping (Element) async throws -> T) -> Single<T> {
        
        let runExpression: (Element) throws -> Single<T> = { element in
            
            return Single.create { callback in
                
                let task = Task {
                    do {
                        let result = try await expression(element)
                        callback(.success(result))
                        
                    } catch {
                        callback(.failure(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}


@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension PrimitiveSequenceType where Trait == MaybeTrait {
    
    func flatMap<T>(do expression: @escaping (Element) async throws -> T?) -> Maybe<T> {
        
        let runExpression: (Element) throws -> Maybe<T> = { element in
            
            return Maybe.create { callback in
                
                let task = Task {
                    do {
                        if  let result = try await expression(element) {
                            callback(.success(result))
                        } else {
                            callback(.completed)
                        }
                        
                        
                    } catch {
                        callback(.error(error))
                    }
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}


@available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public extension InfallibleType {
    
    func flatMap<T>(do expression: @escaping (Element) async -> T?) -> Infallible<T> {
        
        let runExpression: (Element) -> Infallible<T> = { element in
            
            return Infallible.create { callback in
                
                let task = Task {
                    if let result = await expression(element) {
                        callback(.next(result))
                    }
                    callback(.completed)
                }
                
                return Disposables.create { task.cancel() }
            }
        }
        
        return self.flatMap(runExpression)
    }
}
#endif
