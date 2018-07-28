
import Foundation

protocol Keyed {
    var key: String? { get set }
}

// Create a new instance using a genetic type
//let paginationHelper = MGPaginationHelper<Post>()

// Generic class type



//   1. initial - no data has been loaded yet
//   2.  ready - ready and waiting for next request to paginate and load the next page
//   3.  loading - currently paginating and waiting for data from Firebase
//   4.  end - all data has been paginated

enum PaginationState
{
    case initial
    case ready
    case loading
    case end
}

class PaginationHelper<T : Keyed>
{
    // MARK: - Properties
    
    // 1. page size - Determines the number of posts that will be on each page
    // 2. serviceMethod - The service method that will return paginated data
    // 3. state - The current pagination state of the helper
    // 4. lastobjectKey - Firebase uses object keys to determine the last position of the page. We'lll need to use this as an offset for paginating.
    let pageSize: UInt
    let serviceMethod: (UInt, String?,String?, @escaping (([T],String) -> Void)) -> Void
    var state: PaginationState = .initial
    var lastObjectKey: String?
    var category: String?
    
    // MARK: - Init
    //    Can change the default page size for our helper
    //    Set the service method that will be paginated and return data
    init(pageSize: UInt = 2, serviceMethod: @escaping (UInt, String?,String?, @escaping (([T],String) -> Void)) -> Void) {
        self.pageSize = pageSize
        self.serviceMethod = serviceMethod
    }
    
    
    // 1 Notice our completion parameter type. We use our generic type to enforce that we return type T.
    func paginate(completion: @escaping([T]) -> Void)
    {
        // 2 We switch on our helper's state to determine the behavior of our helper when paginate(completion:) is called
        switch state
        {
        // 3 For our initial state, we make sure that the lastObjectKey is nil use the fallthrough keyword to execute the ready case below.
        case .initial:
            lastObjectKey = nil
            fallthrough
        //4 For our ready state, we make sure to change the state to loading and execute our service method to return the paginated data.
        case .ready:
            state = .loading
            //  print(lastObjectKey)
            serviceMethod(pageSize, lastObjectKey ?? nil, category) { [unowned self] (objects: [T], key: String) in
                //5 We use the defer keyword to make sure the following code is executed whenever the closure returns. This is helpful for removing duplicate code.
                defer {
                    //6 If the returned last returned object has a key value, we store that in lastObjectKey to use as a future offset for paginating. Right now the compiler will throw an error because it cannot infer that T has a property of key. We'll fix that next.
                    if let lastObjectKey = objects.last?.key {
                        self.lastObjectKey = key
                        //  print(self.lastObjectKey)
                        //  print(lastObjectKey)
                    }
                    // 7 We determine if we've paginated through all content because if the number of objects returned is less than the page size, we know that we're only the last page of objects.
                    self.state = objects.count < Int(self.pageSize-1) ? .end : .ready
                }
                
                // 8 If lastObjectKey of the helper doesn't exist, we know that it's the first page of data so we return the data as is.
                guard let _ = self.lastObjectKey else {
                    // print(self.lastObjectKey)
                    return completion(objects)
                }
                // 9 Due to implementation details of Firebase, whenever we page with the lastObjectKey, the previous object from the last page is returned. Here we need to drop the first object which will be a duplicate post in our timeline. This happens whenever we're no longer on the first page.
                //  print(objects.last?.key)
                //  let newObjects = Array(objects.dropLast())
                //  print(newObjects)
                //                print("\n")
                //  print(objects)
                //                print("\n")
                completion(objects)
                
            }
            
        //10 If the helper is currently paginating or has no more content, the helper returns and doesn't do anything.
        case . loading, .end:
            return
        }
    }
    
    //  resets the pagination helper to it's initial state
    func reloadData(completion: @escaping ([T]) -> Void)
    {
        state = .initial
        paginate(completion: completion)
    }
    
    
}
