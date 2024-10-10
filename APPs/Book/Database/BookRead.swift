import Foundation
import SwiftUICore
import OSLog
import SwiftData

extension DB {
    func getBookCount() -> Int {
        do {
            return try context.fetchCount(Book.descriptorAll)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
            
            return 0
        }
    }

    func getBookCountOfNoCoverData() -> Int {
        do {
            return try context.fetchCount(Book.descriptorOfShouldUpdateCover)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
            
            return 0
        }
    }

    func getBooksShouldUpdateCover() -> [Book] {
        do {
            return try context.fetch(Book.descriptorOfShouldUpdateCover)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
            
            return []
        }
    }
    
    func getBooksOfCollectionType() -> [Book] {
        do {
            return try context.fetch(Book.descriptorOfFolder)
        } catch {
            os_log(.error, "\(error.localizedDescription)")
            
            return []
        }
    }
}

// MARK: First

extension DB {
    static func firstBook(context: ModelContext) -> Book? {
        var descriptor = FetchDescriptor<Book>(predicate: #Predicate<Book> {
            $0.bookTitle != ""
        }, sortBy: [
            SortDescriptor(\.order, order: .forward),
        ])
        descriptor.fetchLimit = 1

        do {
            return try context.fetch(descriptor).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

    /// 第一个
    nonisolated func firstBook() -> Book? {
        Self.firstBook(context: ModelContext(self.modelContainer))
    }
}

// MARK: Find

extension DB {
    static func findBook(_ url: URL, context: ModelContext, verbose: Bool = false) -> Book? {
        if verbose {
            os_log("\(self.label)FindBook -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(Book.descriptorOf(url)).first
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }
    
    func findBook(_ url: URL) -> Book? {
        Self.findBook(url, context: context)
    }
    
    func findBook(_ id: Book.ID) -> Book? {
        context.model(for: id) as? Book
    }
    
    func findOrCreateBook(_ url: URL) -> Book? {
        if let book = self.findBook(url) {
            return book
        } else {
            let book = Book(url: url)
            context.insert(Book(url: url))
            
//            do {
//                try context.save()
//            } catch {
//                os_log(.error, "\(error.localizedDescription)")
//            }
            return book
//            return self.findBook(url)
        }
    }
}

// MARK: Children

extension DB {
    func getChildren(_ url: URL, verbose: Bool = true) -> [Book] {
        if verbose {
            os_log("\(self.t)GetChildren -> \(url.lastPathComponent)")
        }
        
        do {
            return try context.fetch(FetchDescriptor<Book>(predicate: #Predicate<Book> {
                $0.url.absoluteString == url.absoluteString
            }))
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return []
    }
}


// MARK: Next

extension DB {
    nonisolated func getNextBookOf(_ url: URL?, verbose: Bool = false) -> Book? {
        if verbose {
            os_log("\(Logger.isMain)\(Self.label)NextBookOf -> \(url?.lastPathComponent ?? "-")")
        }
        
        guard let url = url else {
            return nil
        }
        
        let context = ModelContext(self.modelContainer)
        guard let book = Self.findBook(url, context: context) else {
            return nil
        }
        
        return Self.nextBookOf(context: context, book: book)
    }
    
    /// The next one of provided URL
    func nextBookOf(_ url: URL?, verbose: Bool = false) -> Book? {
        if verbose {
            os_log("\(self.t)NextBookOf -> \(url?.lastPathComponent ?? "-")")
        }
        
        guard let url = url else {
            return nil
        }
        
        guard let book = self.findBook(url) else {
            return nil
        }
        
        return self.nextBookOf(book)
    }

    /// The next one of provided Book
    func nextBookOf(_ book: Book) -> Book? {
        Self.nextBookOf(context: context, book: book)
    }
    
    static func nextBookOf(context: ModelContext, book: Book) -> Book? {
        //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title)")
        let order = 1
        let url = book.url
        var descriptor = FetchDescriptor<Book>()
        descriptor.sortBy.append(.init(\.order, order: .forward))
        descriptor.fetchLimit = 1
        descriptor.predicate = #Predicate {
            $0.order >= order && $0.url != url
        }

        do {
            let result = try context.fetch(descriptor)
            let next = result.first ?? Self.firstBook(context: context)
            //os_log("🍋 DBAudio::nextOf [\(audio.order)] \(audio.title) -> [\(next?.order ?? -1)] \(next?.title ?? "-")")
            return next
        } catch let e {
            os_log(.error, "\(e.localizedDescription)")
        }

        return nil
    }

//    func getBooks(filter: BookFilter) async throws -> [Book] {
//        var descriptor = FetchDescriptor<Book>()
//        descriptor.predicate = filter.predicate
//        descriptor.sortBy = [SortDescriptor(\.order, order: .forward)]
//        return try context.fetch(descriptor)
//    }
}

// MARK: Cover

extension DB {
    func getCover(_ bookURL: URL) async -> Image? {
        guard let book = self.findBook(bookURL) else {
            return nil
        }
        
        if let image = await book.getBookCoverFromDB() {
            return image
        }
        
        if let parent = self.findBook(bookURL.deletingLastPathComponent()) {
            return await self.getCover(parent.url)
        }
        
        return nil
    }
}

// MARK: Descriptor

extension Book {
    static var descriptorOfShouldUpdateCover: FetchDescriptor<Book> {
        FetchDescriptor<Book>(predicate: #Predicate<Book> {
            $0.hasGetCover == false
        })
    }

    static var descriptorOfFolder: FetchDescriptor<Book> {
        FetchDescriptor<Book>(predicate: #Predicate<Book> {
            $0.isCollection == true
        })
    }
}

// MARK: - BookFilter

struct BookFilter {
    private var isCollectionPredicate: (Predicate<Book>, Bool)?
    private var titlePredicate: (Predicate<Book>, Bool)?
    private var pathExtensionPredicate: (Predicate<Book>, Bool)?
    
    var predicate: Predicate<Book> {
        #Predicate<Book> { book in
            (self.isCollectionPredicate.map { $0.1 ? $0.0.evaluate(book) : true } ?? true) &&
            (self.titlePredicate.map { $0.1 ? $0.0.evaluate(book) : true } ?? true) &&
            (self.pathExtensionPredicate.map { $0.1 ? $0.0.evaluate(book) : true } ?? true)
        }
    }
    
    init() {}
    
    func isCollection(_ value: Bool, enabled: Bool = true) -> BookFilter {
        var newFilter = self
        newFilter.isCollectionPredicate = (#Predicate<Book> { $0.isCollection == value }, enabled)
        return newFilter
    }
    
    func title(_ value: String, enabled: Bool = true) -> BookFilter {
        var newFilter = self
        newFilter.titlePredicate = (#Predicate<Book> { $0.bookTitle == value }, enabled)
        return newFilter
    }
    
    func pathExtension(_ value: String, enabled: Bool = true) -> BookFilter {
        var newFilter = self
        newFilter.pathExtensionPredicate = (#Predicate<Book> { $0.url.pathExtension == value }, enabled)
        return newFilter
    }
}

extension DB {
    func getBooks(filter: BookFilter) async throws -> [Book] {
        var descriptor = FetchDescriptor<Book>()
        descriptor.predicate = filter.predicate
        descriptor.sortBy = [SortDescriptor(\.order, order: .forward)]
        return try context.fetch(descriptor)
    }
}
