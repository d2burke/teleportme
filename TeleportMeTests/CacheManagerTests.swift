import Testing
import Foundation
@testable import TeleportMe

// MARK: - CacheManager Tests

/// These tests use the real CacheManager singleton with unique test-specific user IDs
/// to avoid interference. Each test cleans up after itself.
struct CacheManagerTests {

    private let testUserId = "test-cache-\(UUID().uuidString)"
    private let cache = CacheManager.shared

    // MARK: - CacheKey Tests

    @Test func cacheKey_globalKeys_areGlobal() {
        #expect(CacheKey.cities.isGlobal)
        #expect(CacheKey.cityScores.isGlobal)
        #expect(CacheKey.analyticsQueue.isGlobal)
    }

    @Test func cacheKey_perUserKeys_notGlobal() {
        #expect(!CacheKey.savedCities(userId: "x").isGlobal)
        #expect(!CacheKey.currentReport(userId: "x").isGlobal)
        #expect(!CacheKey.preferences(userId: "x").isGlobal)
        #expect(!CacheKey.explorations(userId: "x").isGlobal)
    }

    @Test func cacheKey_globalKeys_haveNoUserId() {
        #expect(CacheKey.cities.userId == nil)
        #expect(CacheKey.cityScores.userId == nil)
        #expect(CacheKey.analyticsQueue.userId == nil)
    }

    @Test func cacheKey_perUserKeys_haveUserId() {
        #expect(CacheKey.savedCities(userId: "abc").userId == "abc")
        #expect(CacheKey.currentReport(userId: "xyz").userId == "xyz")
    }

    @Test func cacheKey_differentUserIds_differentPaths() {
        let key1 = CacheKey.preferences(userId: "user-1")
        let key2 = CacheKey.preferences(userId: "user-2")
        #expect(key1.userId != key2.userId)
    }

    @Test func cacheKey_filenames() {
        #expect(CacheKey.cities.filename == "cities.json")
        #expect(CacheKey.cityScores.filename == "city_scores.json")
        #expect(CacheKey.savedCities(userId: "x").filename == "saved_cities.json")
        #expect(CacheKey.currentReport(userId: "x").filename == "current_report.json")
        #expect(CacheKey.pastReports(userId: "x").filename == "past_reports.json")
        #expect(CacheKey.preferences(userId: "x").filename == "preferences.json")
        #expect(CacheKey.selectedCity(userId: "x").filename == "selected_city.json")
        #expect(CacheKey.explorations(userId: "x").filename == "explorations.json")
        #expect(CacheKey.analyticsQueue.filename == "analytics_queue.json")
    }

    // MARK: - Save & Load Tests

    @Test func saveAndLoad_codableType() {
        let key = CacheKey.preferences(userId: testUserId)
        let prefs = UserPreferences.defaults

        cache.save(prefs, for: key)
        let result = cache.load(UserPreferences.self, for: key)

        #expect(result != nil)
        #expect(result?.data.costPreference == 5.0)
        #expect(result?.data.climatePreference == 5.0)

        // Cleanup
        cache.clearUserCache(userId: testUserId)
    }

    @Test func load_nonExistentKey_returnsNil() {
        let key = CacheKey.preferences(userId: "nonexistent-\(UUID().uuidString)")
        let result = cache.load(UserPreferences.self, for: key)
        #expect(result == nil)
    }

    @Test func save_overwritesExistingData() {
        let key = CacheKey.preferences(userId: testUserId)

        var prefs1 = UserPreferences.defaults
        prefs1.costPreference = 3.0
        cache.save(prefs1, for: key)

        var prefs2 = UserPreferences.defaults
        prefs2.costPreference = 8.0
        cache.save(prefs2, for: key)

        let result = cache.load(UserPreferences.self, for: key)
        #expect(result?.data.costPreference == 8.0)

        // Cleanup
        cache.clearUserCache(userId: testUserId)
    }

    @Test func load_freshData_isNotStale() {
        let key = CacheKey.preferences(userId: testUserId)
        cache.save(UserPreferences.defaults, for: key)

        // TTL of 1 hour — data is fresh (just saved)
        let result = cache.load(UserPreferences.self, for: key, ttl: 3600)
        #expect(result?.isStale == false)

        // Cleanup
        cache.clearUserCache(userId: testUserId)
    }

    @Test func load_withZeroTTL_isStale() {
        let key = CacheKey.preferences(userId: testUserId)
        cache.save(UserPreferences.defaults, for: key)

        // TTL of 0 — everything is stale
        let result = cache.load(UserPreferences.self, for: key, ttl: 0)
        #expect(result?.isStale == true)
        // But data is still returned
        #expect(result?.data != nil)

        // Cleanup
        cache.clearUserCache(userId: testUserId)
    }

    // MARK: - Removal Tests

    @Test func remove_deletesFile() {
        let key = CacheKey.preferences(userId: testUserId)
        cache.save(UserPreferences.defaults, for: key)

        cache.remove(for: key)
        let result = cache.load(UserPreferences.self, for: key)
        #expect(result == nil)

        // Cleanup
        cache.clearUserCache(userId: testUserId)
    }

    @Test func clearUserCache_removesAllUserFiles() {
        let key1 = CacheKey.preferences(userId: testUserId)
        let key2 = CacheKey.explorations(userId: testUserId)

        cache.save(UserPreferences.defaults, for: key1)
        cache.save([String](), for: key2)

        cache.clearUserCache(userId: testUserId)

        #expect(cache.load(UserPreferences.self, for: key1) == nil)
        #expect(cache.load([String].self, for: key2) == nil)
    }

    // MARK: - CachedData Tests

    @Test func cachedData_staleness() {
        let recent = CachedData(data: "test", cachedAt: Date())
        #expect(!recent.isStale(ttl: 3600))

        let old = CachedData(data: "test", cachedAt: Date().addingTimeInterval(-7200))
        #expect(old.isStale(ttl: 3600))
    }

    @Test func cachedData_age() {
        let fiveMinutesAgo = Date().addingTimeInterval(-300)
        let cached = CachedData(data: "test", cachedAt: fiveMinutesAgo)
        #expect(cached.age >= 299 && cached.age <= 301)
    }
}
