//
//  gridtokexiosTests.swift
//  gridtokexiosTests
//
//  Created by Chanthawat Kiriyadee on 20/6/2569 BE.
//

import Testing
@testable import gridtokexios

struct gridtokexiosTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // Swift Testing Documentation
        // https://developer.apple.com/documentation/testing
    }

}

// MARK: - LiveTradeQuote (live dashboard trade math)

struct LiveTradeQuoteTests {

    private let eps = 1e-9

    @Test func presetDerivesAmountAndTotal() {
        // 50% of 12.4 kWh = 6.20 kWh; × ฿4.32 = ฿26.784.
        let q = LiveTradeQuote(side: .buy, preset: 50)
        #expect(abs(q.amount - 6.2) < eps)
        #expect(abs(q.total - 26.784) < eps)
    }

    @Test func maxPresetUsesFullAvailability() {
        let q = LiveTradeQuote(side: .sell, preset: 100)
        #expect(abs(q.amount - 12.4) < eps)
        #expect(abs(q.total - 53.568) < eps)
    }

    @Test func quarterAndThreeQuarterPresets() {
        #expect(abs(LiveTradeQuote(side: .buy, preset: 25).amount - 3.1) < eps)
        #expect(abs(LiveTradeQuote(side: .buy, preset: 75).amount - 9.3) < eps)
    }

    @Test func nilPresetIsZero() {
        let q = LiveTradeQuote(side: .buy, preset: nil)
        #expect(q.amount == 0)
        #expect(q.total == 0)
        #expect(q.ctaLabel == "Buy 0.00 kWh · ฿0.00")
    }

    @Test func ctaLabelBuyAndSell() {
        #expect(LiveTradeQuote(side: .buy, preset: 50).ctaLabel == "Buy 6.20 kWh · ฿26.78")
        #expect(LiveTradeQuote(side: .sell, preset: 50).ctaLabel == "Sell 6.20 kWh · ฿26.78")
    }

    @Test func ctaLabelDCAIsStatic() {
        // DCA ignores amount/total — it sets up a recurring plan, not an order.
        #expect(LiveTradeQuote(side: .dca, preset: 50).ctaLabel == "Set up DCA")
        #expect(LiveTradeQuote(side: .dca, preset: nil).ctaLabel == "Set up DCA")
    }
}

// MARK: - DCA plan (09 · DCA strategy)

struct DCAPlanTests {
    @Test func unitAndSingularPerFrequency() {
        func plan(_ f: String) -> DCAPlan { DCAPlan(side: .buy, amount: "3.0", freq: f, everyN: "1", maxPrice: "") }
        #expect(plan("hourly").unit == "hours")
        #expect(plan("daily").unit == "days")
        #expect(plan("weekly").unit == "weeks")
        #expect(plan("monthly").unit == "months")
        #expect(plan("daily").unitSingular == "day")
        #expect(plan("weekly").unitSingular == "week")
    }

    @Test func unknownFrequencyFallsBack() {
        let p = DCAPlan(side: .buy, amount: "3.0", freq: "yearly", everyN: "1", maxPrice: "")
        #expect(p.unit == "days")
        #expect(p.cadence == "Daily")
        #expect(p.nextRun == "Tomorrow")
    }

    @Test func startLabelUsesSingularUnit() {
        let p = DCAPlan(side: .sell, amount: "2.5", freq: "weekly", everyN: "1", maxPrice: "")
        #expect(p.startLabel == "Start DCA · 2.5 kWh / week")
    }

    @Test func frequencyDetailOnlyShowsIntervalWhenAboveOne() {
        let one = DCAPlan(side: .buy, amount: "3.0", freq: "daily", everyN: "1", maxPrice: "")
        let many = DCAPlan(side: .buy, amount: "3.0", freq: "daily", everyN: "3", maxPrice: "")
        #expect(one.frequencyDetail == "Daily")
        #expect(many.frequencyDetail == "Daily · every 3 days")
    }

    @Test func priceCapFormatsOrFallsBack() {
        #expect(DCAPlan(side: .buy, amount: "3.0", freq: "daily", everyN: "1", maxPrice: "").priceCap == "No limit")
        #expect(DCAPlan(side: .buy, amount: "3.0", freq: "daily", everyN: "1", maxPrice: "4.50").priceCap == "฿4.50/kWh")
    }

    @Test func summaryRowsMatchConfig() {
        let p = DCAPlan(side: .sell, amount: "5.0", freq: "monthly", everyN: "2", maxPrice: "4.80")
        let rows = p.summaryRows
        #expect(rows.map(\.0) == ["Action", "Amount", "Frequency", "Price cap", "Next run"])
        #expect(rows[0].1 == "Sell energy")
        #expect(rows[1].1 == "5.0 kWh")
        #expect(rows[2].1 == "Monthly · every 2 months")
        #expect(rows[3].1 == "฿4.80/kWh")
        #expect(rows[4].1 == "1st of month")
    }
}

// MARK: - Energy flow (10 · Energy flow)

struct FlowSummaryTests {
    private let eps = 1e-9

    @Test func nowFigures() {
        let s = FlowSummary(dataset: .now)
        #expect(abs(s.produced - 10.5) < eps)   // 6.2 + 2.8 + 1.5
        #expect(abs(s.sold - 1.6) < eps)
        #expect(abs(s.used - 8.9) < eps)         // 4.5 + 2.0 + 2.4 (excludes Sold)
        #expect(abs(s.gridBuy - 1.5) < eps)
        #expect(s.selfSufficient == 86)          // (10.5-1.5)/10.5 = 85.7 → 86
    }

    @Test func todayFigures() {
        let s = FlowSummary(dataset: .today)
        #expect(abs(s.produced - 76) < eps)      // 48 + 19 + 9
        #expect(abs(s.sold - 16) < eps)
        #expect(abs(s.used - 60) < eps)          // 34 + 14 + 12
        #expect(s.selfSufficient == 88)          // (76-9)/76 = 88.2 → 88
    }

    @Test func usedExcludesSold() {
        // `used` must never count the Sold sink — it is exported, not consumed.
        let s = FlowSummary(dataset: .now)
        #expect(abs((s.used + s.sold) - 10.5) < eps)
    }
}
