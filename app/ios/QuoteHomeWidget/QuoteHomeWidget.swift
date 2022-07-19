//
//  QuoteHomeWidget.swift
//  QuoteHomeWidget
//
//  Created by dz on 7/19/22.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.app.instantquotes.quotehomewidget"
private let placeHolderQuote = "The best way to predict your future is to create it."
private let placeHolderAuthor = "-- Abraham Lincoln"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: placeHolderQuote, author: placeHolderAuthor)
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        let data = UserDefaults.init(suiteName:widgetGroupId)
        let entry = QuoteEntry(
            date: Date(),
            quote: data?.string(forKey: "quote") ?? placeHolderQuote,
            author: data?.string(forKey: "author") ?? placeHolderAuthor
        );
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: String
    let author: String
}

struct QuoteHomeWidgetEntryView : View {
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName:widgetGroupId)

    var body: some View {
        VStack.init(alignment: .leading, spacing: nil,
            content: {
                Text(entry.quote).bold().font(.title)	
                Text(entry.author)
                    .font(.body)
                    .widgetURL(URL(string: "QuoteHomeWidget://quote?quoteId=\(data?.integer(forKey: "quoteId") ?? 0)&homeWidget"))
            }
        )
    }
}

@main
struct QuoteHomeWidget: Widget {
    let kind: String = "QuoteHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            QuoteHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Random Quote")
        .description("Display a random quote.")
    }
}

struct QuoteHomeWidget_Previews: PreviewProvider {
    static var previews: some View {
        QuoteHomeWidgetEntryView(entry: QuoteEntry(
            date: Date(),
            quote: placeHolderQuote,
            author: placeHolderAuthor
        )).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
