package com.lifequotes.bestquotes

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider
import io.flutter.Log

class QuoteHomeWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget).apply {
                val pendingIntent = HomeWidgetLaunchIntent.getActivity(
                        context,
                        MainActivity::class.java
                )
                setOnClickPendingIntent(R.id.widgetContainer, pendingIntent)

                setText(widgetData, this, R.id.quote, "quote", "The best way to predict your future is to create it.")
                setText(widgetData, this, R.id.author, "author", "-- Abraham Lincoln")
            }

            appWidgetManager.updateAppWidget(widgetId, views)
            onAppWidgetOptionsChanged(context, appWidgetManager, widgetId, null)
        }
    }

    override fun onAppWidgetOptionsChanged(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
            newOptions: Bundle?
    ) {
        val wsp = WidgetSizeProvider(context)
        val ws = wsp.getWidgetCellSize(appWidgetId)
        val editor = HomeWidgetPlugin.getData(context).edit()

        Log.d("QuoteHomeWidgetProvider", "dimensions: $ws")

        editor.putInt("cellWidth", ws.first)
        editor.putInt("cellHeight", ws.second)
        editor.apply()
    }

    private fun setText(sp: SharedPreferences, views: RemoteViews, resId: Int, key: String, dv: String) {
        val str = sp.getString(key, dv)
        views.setTextViewText(resId, str)
    }
}
