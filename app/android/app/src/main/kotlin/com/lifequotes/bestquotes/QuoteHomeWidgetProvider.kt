package com.lifequotes.bestquotes

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class QuoteHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget).apply {
                // Open App on Widget Click
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widgetContainer, pendingIntent)

                setText(widgetData, this, R.id.quote, "quote", "The best way to predict your future is to create it.")
                setText(widgetData, this, R.id.author, "author", "-- Abraham Lincoln")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun setText(sp: SharedPreferences, views: RemoteViews, resId: Int, key: String, dv: String) {
        val str = sp.getString(key, dv)
        views.setTextViewText(resId, str)
    }
}
