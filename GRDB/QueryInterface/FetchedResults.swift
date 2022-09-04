import Dispatch
import Foundation

public final class FetchedResults<Element> {
    private class Page {
        let elements: [Element]
        
        init(elements: [Element]) {
            self.elements = elements
        }
    }
    
    typealias FetchAll = (_ db: Database, _ request: Request, _ minimumCapacity: Int) throws -> [Element]
    typealias Request = QueryInterfaceRequest<Element>
    let request: Request
    let snapshot: DatabaseSnapshot
    private let fetchAll: FetchAll
    public let count: Int
    private let pageSize = 100
    private let pageCount: Int
    private var cachedPages: NSCache<NSNumber, Page>
    private var prefetchingPageIndices: Set<Int> = []
    private var operationQueue: OperationQueue
    
    private var extraPages: Int {
        get {
            Swift.max(0, cachedPages.countLimit - 3) / 2
        }
        set {
            cachedPages.countLimit = newValue * 2 + 3
        }
    }
    private var pageFetchDuration: TimeInterval = 0
    
    init(
        request: QueryInterfaceRequest<Element>,
        snapshot: DatabaseSnapshot,
        fetchAll: @escaping FetchAll)
    throws
    {
        self.request = request
        self.snapshot = snapshot
        self.fetchAll = fetchAll
        self.count = try snapshot.unsafeReentrantRead { db in
            // Report the full observed region (including prefetched associations)
            if db.isRecordingSelectedRegion {
                let preparedRequest = try request.makePreparedRequest(db)
                db.selectedRegion.formUnion(preparedRequest.statement.databaseRegion)
            }
            
            return try request.fetchCount(db)
        }
        self.pageCount = 1 + (count - 1) / pageSize
        self.cachedPages = NSCache()
        self.operationQueue = OperationQueue()
        self.extraPages = 3
        
        operationQueue.maxConcurrentOperationCount = 1
    }
    
    private func hasCachedPage(at pageIndex: Int) -> Bool {
        cachedPages.object(forKey: NSNumber(value: pageIndex)) != nil
    }
    
    private func cachedPage(at pageIndex: Int) -> Page? {
        cachedPages.object(forKey: NSNumber(value: pageIndex))
    }
    
    private func setCachedPage(_ page: Page, at pageIndex: Int) {
        cachedPages.setObject(page, forKey: NSNumber(value: pageIndex))
    }
    
    @inline(__always)
    private func pageIndex(forElementAt index: Index) -> Int {
        index / pageSize
    }
    
    private func requestForPage(at pageIndex: Int) -> QueryInterfaceRequest<Element> {
        request.limit(pageSize, offset: pageIndex * pageSize)
    }
    
    private func fetchPage(_ db: Database, at pageIndex: Int) throws -> Page {
        let elements = try fetchAll(db, requestForPage(at: pageIndex), pageSize)
        return Page(elements: elements)
    }
}

// MARK: - UITableViewDataSourcePrefetching

extension FetchedResults {
    public func prefetchResultsAt(_ indexes: some Collection<Int>) {
        GRDBPrecondition(Thread.isMainThread, "Not the main thread")
        
        var firstPageIndex: Int?
        var lastPageIndex: Int?
        for index in indexes {
            let pageIndex = pageIndex(forElementAt: index)
            if firstPageIndex == nil || firstPageIndex! > pageIndex { firstPageIndex = pageIndex }
            if lastPageIndex == nil || lastPageIndex! < pageIndex { lastPageIndex = pageIndex }
        }
        guard let firstPageIndex, let lastPageIndex else { return }
        
        // Pages to prefetch, in the order of prefetch
        var pageIndices = Array(firstPageIndex...lastPageIndex)
        if extraPages > 0 {
            for i in 1..<extraPages {
                let pageIndex = lastPageIndex + i
                if pageIndex >= pageCount { break }
                pageIndices.append(pageIndex)
            }
            for i in 1..<extraPages {
                let pageIndex = firstPageIndex - i
                if pageIndex < 0 { break }
                pageIndices.append(pageIndex)
            }
        }
        
        prefetchPages(at: pageIndices)
    }
    
    public func cancelPrefetchResultsAt(_ indexes: some Collection<Int>) {
    }
    
    private func prefetchPages(at pageIndices: some Collection<Int>) {
        assert(Thread.isMainThread, "Not the main thread")
        
        let pageIndices = pageIndices.filter { pageIndex in
            if hasCachedPage(at: pageIndex) {
                // Already cached
                return false
            }
            if prefetchingPageIndices.contains(pageIndex) {
                // Already prefetching
                return false
            }
            return true
        }
        
        guard let pageIndex = pageIndices.first else {
            return
        }
        
        for pageIndex in pageIndices {
            prefetchingPageIndices.insert(pageIndex)
        }
        
        operationQueue.addOperation(BlockOperation { [self] in
            do {
                let page = try snapshot.read { db in
                    try fetchPage(db, at: pageIndex)
                }
                        
                DispatchQueue.main.async { [self] in
                    setCachedPage(page, at: pageIndex)
                    prefetchingPageIndices.remove(pageIndex)
                    prefetchPages(at: pageIndices.dropFirst())
                }
            } catch { }
        })
    }
}

// MARK: - RandomAccessCollection

extension FetchedResults: RandomAccessCollection {
    public var startIndex: Int { 0 }
    public var endIndex: Int { count }
    
    public subscript(position: Int) -> Element {
        GRDBPrecondition(Thread.isMainThread, "Not the main thread")
        
        let pageIndex = pageIndex(forElementAt: position)
        if let page = cachedPage(at: pageIndex) {
            return page.elements[position - pageIndex * pageSize]
        }
        
        operationQueue.cancelAllOperations()
        prefetchingPageIndices.removeAll()
        snapshot.interrupt()
        if extraPages < 10 { extraPages += 1 }
        
        let page = try! snapshot.unsafeReentrantRead { db in
            try cachedPage(at: pageIndex) ?? fetchPage(db, at: pageIndex)
        }
        setCachedPage(page, at: pageIndex)
        
        prefetchResultsAt([position])
        return page.elements[position - pageIndex * pageSize]
    }
}

// MARK: - DatabaseValueConvertible

extension QueryInterfaceRequest where RowDecoder: DatabaseValueConvertible {
    public func fetchResults(_ snapshot: DatabaseSnapshot) throws -> FetchedResults<RowDecoder> {
        try FetchedResults(
            request: self,
            snapshot: snapshot,
            fetchAll: { db, request, minimumCapacity in
                try Array(request.fetchCursor(db), minimumCapacity: minimumCapacity)
            })
    }
}

// MARK: - DatabaseValueConvertible & StatementColumnConvertible

extension QueryInterfaceRequest where RowDecoder: DatabaseValueConvertible & StatementColumnConvertible {
    public func fetchResults(_ snapshot: DatabaseSnapshot) throws -> FetchedResults<RowDecoder> {
        try FetchedResults(
            request: self,
            snapshot: snapshot,
            fetchAll: { db, request, minimumCapacity in
                try Array(request.fetchCursor(db), minimumCapacity: minimumCapacity)
            })
    }
}

// MARK: - Record

extension QueryInterfaceRequest where RowDecoder: FetchableRecord {
    public func fetchResults(_ snapshot: DatabaseSnapshot) throws -> FetchedResults<RowDecoder> {
        try FetchedResults(
            request: self,
            snapshot: snapshot,
            fetchAll: { db, request, minimumCapacity in
                try Array(request.fetchCursor(db), minimumCapacity: minimumCapacity)
            })
    }
}

// MARK: - Row

extension QueryInterfaceRequest where RowDecoder == Row {
    public func fetchResults(_ snapshot: DatabaseSnapshot) throws -> FetchedResults<RowDecoder> {
        try FetchedResults(
            request: self,
            snapshot: snapshot,
            fetchAll: { db, request, minimumCapacity in
                try Array(request.fetchCursor(db), minimumCapacity: minimumCapacity)
            })
    }
}
