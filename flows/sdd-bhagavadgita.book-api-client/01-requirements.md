# Requirements: Legacy API Client

> Version: 1.0
> Status: DRAFT
> Last Updated: 2026-04-29
> Source: Legacy iOS/Android code analysis

## Problem Statement

The Flutter app needs an API client that communicates with the existing Bhagavad Gita backend. Analysis of legacy implementations (Swift `GitaRequestManager`, Java `DataService`) reveals a specific pattern:
- All endpoints use POST method
- All responses wrapped in `{code, data, message}`
- 4 main data endpoints

This spec documents the exact API client behavior extracted from legacy code.

## User Stories

### Primary

**As a** Flutter app
**I want** to fetch content from the backend API
**So that** users can access latest books, chapters, and slokas

### Secondary

**As a** developer
**I want** type-safe API responses
**So that** I can avoid runtime parsing errors

## Legacy Implementation Analysis

### Swift: GitaRequestManager.swift

```swift
// Line 15-18
static let kHostUrl: String = "http://app.bhagavadgitaapp.online"
static let kServerUrl: String = kHostUrl + "/api/"

// Line 21-28: Response codes
override func supportedResponseCodes() -> Set<Int> {
    return Set<Int>([200, 201, 401, 500])
}

// Line 41-59: Response processing
override func processReceivedData(_ responseObj: Any, with state: RequestManagerState) -> Any {
    guard let jsonDataDic = responseObj as? NSDictionary else { return responseObj }
    let code = jsonDataDic["code"] as? Int
    let data = jsonDataDic["data"]
    let message = jsonDataDic["message"] as? String

    if code ?? 0 == 0, let data = data {
        return data  // Success: return just the data
    }
    // Error: return RequestError object
}

// Line 84-98: getLanguages
static func getLanguages(...) -> Self? {
    return self.runRequest(requestMethodUrl: "Data/Languages",
                           params: [:], ...)
}

// Line 101-115: getBooks
static func getBooks(ids: [Int] = [], ...) -> Self? {
    return self.runRequest(requestMethodUrl: "Data/Books",
                           params: ["params": ["ids" : ids]], ...)
}

// Line 118-137: getChapters
static func getChapters(bookId: Int, ...) -> Self? {
    return self.runRequest(requestMethodUrl: "Data/Chapters",
                           params: ["params": ["bookId" : bookId]], ...)
    // Note: fills bookId on each chapter client-side (line 131)
}

// Line 140-151: getQuote
static func getQuote(...) -> Self? {
    return self.runRequest(requestMethodUrl: "Data/Quotes",
                           params: [:], ...)
}
```

### Java: DataService.java

```java
// Line 13-16
public static void getLanguages(boolean publishProgress, OnCallListener listener) {
    new GitaRequest(NAME + "Languages")
        .setResultClass(Languages.class).call(listener);
}

// Line 18-20
public static void getBooks(Collection<Integer> ids, ...) {
    new GitaRequest(NAME + "Books")
        .buildParams("ids", ids).call(listener);
}

// Line 22-29
public static void getChapters(int bookId, ...) {
    new GitaRequest(NAME + "Chapters")
        .buildParams("bookId", bookId).call(listener);
}

// Line 31-33
public static void getQuote(OnCallListener listener) {
    new GitaRequest(NAME + "Quotes").call(listener);
}
```

## Acceptance Criteria

### Must Have

1. **Given** a network request to `Data/Languages`
   **When** the response has `code: 0`
   **Then** return parsed list of Language objects

2. **Given** a network request to `Data/Books` with language IDs
   **When** the response has `code: 0`
   **Then** return parsed list of Book objects

3. **Given** a network request to `Data/Chapters` with bookId
   **When** the response has `code: 0`
   **Then** return parsed list of Chapter objects with nested Slokas and Vocabularies

4. **Given** a network request to `Data/Quotes`
   **When** the response has `code: 0`
   **Then** return parsed Quote object

5. **Given** any response with `code != 0`
   **When** processing response
   **Then** throw ApiException with code and message

### Should Have

- Request timeout handling (30 seconds default)
- Retry logic for transient failures
- Logging of requests/responses for debugging

### Won't Have (This Iteration)

- Request caching (handled by repository layer)
- Offline queue (handled by sync orchestrator)
- Authentication (API is public)

## Constraints

- **Technical**: Must use POST for all endpoints
- **Technical**: Must handle `{code, data, message}` wrapper
- **Network**: Base URL is `http://app.bhagavadgitaapp.online/api/`
- **Dependencies**: Use `dio` or `http` package

## Open Questions

- [x] Are endpoints public or require auth? → **Public (no auth)**
- [x] What's the timeout? → **Legacy uses system default, recommend 30s**
- [ ] Should we support request cancellation?

## References

- Swift source: `legacy/legacy_bhagavadgita.book_swift/Gita/Model/DataAccess/GitaRequestManager.swift`
- Java source: `legacy/legacy_bhagavadgita.book_java/app/src/main/java/com/ethnoapp/bgita/server/DataService.java`
- ADR-001: API Contract Design

---

## Approval

- [ ] Reviewed by: [name]
- [ ] Approved on: [date]
- [ ] Notes: [any conditions or clarifications]
