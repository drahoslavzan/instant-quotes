//
//  QuoteHomeWidget.swift
//  QuoteHomeWidget
//
//  Created by dz on 7/19/22.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.app.instantquotes.quotehomewidget"

private let placeHolderQid = 3474
private let placeHolderQuote = "Be sure you put your feet in the right place, then stand firm."
private let placeHolderAuthor = "-- Abraham Lincoln"

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> QuoteEntry {
        let data = UserDefaults.init(suiteName: widgetGroupId)
        return QuoteEntry(
            date: Date(),
            qid: { $0 == 0 ? placeHolderQid : $0 }(data?.integer(forKey: "qid") ?? 0),
            quote: data?.string(forKey: "quote") ?? placeHolderQuote,
            author: data?.string(forKey: "author") ?? placeHolderAuthor
        );
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> ()) {
        // TODO: allow only one instance of widget (no multiple sizes)
        let data = UserDefaults.init(suiteName: widgetGroupId)
        let sw = context.displaySize.width
        let sh = context.displaySize.height
        let mql = ceil(sw / 14) * ceil(sh / 32)
        data?.setValue(Int(mql), forKey: "maxQuoteLen")

        let entry = placeholder(in: context)
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
    let qid: Int
    let quote: String
    let author: String
}

struct QuoteHomeWidgetEntryView : View {
    var entry: Provider.Entry
    
    var body: some View {
        VStack.init(
            alignment: .leading,
            spacing: 8,
            content: {
                Text(entry.quote)
                    .font(.body)
                Text(entry.author)
                    .font(.caption)
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .widgetURL(URL(string: "QuoteHomeWidget://quote?qid=\(entry.qid)&homeWidget"))
            }
        ).padding(12)
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
            qid: placeHolderQid,
            quote: placeHolderQuote,
            author: placeHolderAuthor
        )).previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
