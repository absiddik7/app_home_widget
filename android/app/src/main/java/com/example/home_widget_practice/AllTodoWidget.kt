package com.example.home_widget_practice

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class AllTodoWidget : AppWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray) {
        for (appWidgetId in appWidgetIds) {
            // Adapter intent for the list view
            val serviceIntent = Intent(context, AllTodoWidgetService::class.java).apply {
                putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId)
                data = Uri.parse(toUri(Intent.URI_INTENT_SCHEME))
            }

            // RemoteViews to control the widget layout
            val views = RemoteViews(context.packageName, R.layout.all_todo_widget).apply {
                setTextViewText(R.id.widget_title, "Today's Tasks")
                setRemoteAdapter(R.id.widget_list, serviceIntent)
                setEmptyView(R.id.widget_list, R.id.empty_view)
            }

            // App launch intent for the plus icon
            val launchIntent = Intent(context, MainActivity::class.java)
            launchIntent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            val pendingIntent = PendingIntent.getActivity(
                context,
                0,
                launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            // Connect plus icon with launch intent
            views.setOnClickPendingIntent(R.id.widget_add_icon, pendingIntent)

            // Update the widget
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }


    override fun onEnabled(context: Context) {
        // Optional: logic for when the first widget is created
    }

    override fun onDisabled(context: Context) {
        // Optional: logic for when the last widget is removed
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)

        val appWidgetManager = AppWidgetManager.getInstance(context)
        val thisWidget = ComponentName(context, AllTodoWidget::class.java)
        val appWidgetIds = appWidgetManager.getAppWidgetIds(thisWidget)

        if (intent.action == AppWidgetManager.ACTION_APPWIDGET_UPDATE ||
            intent.action ==  "com.example.home_widget_practice") {

            appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.widget_list)
            onUpdate(context, appWidgetManager, appWidgetIds)
        }
    }



}
