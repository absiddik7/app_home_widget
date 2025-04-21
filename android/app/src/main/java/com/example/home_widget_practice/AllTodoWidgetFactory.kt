package com.example.home_widget_practice

import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import android.widget.RemoteViewsService
import es.antonborri.home_widget.HomeWidgetPlugin
import org.json.JSONArray
import org.json.JSONException

class AllTodoWidgetFactory(private val context: Context) : RemoteViewsService.RemoteViewsFactory {

    private var tasks: MutableList<String> = mutableListOf()

    override fun onCreate() {}

    override fun onDataSetChanged() {
        val data = HomeWidgetPlugin.getData(context)
        val json = data.getString("todo_data_key", null)
        try {
            val array = JSONArray(json)
            tasks.clear()
            for (i in 0 until array.length()) {
                val obj = array.getJSONObject(i)
                val title = obj.getString("title")
                val isCompleted = obj.getBoolean("isCompleted")
                val symbol = if (isCompleted) "\u2611" else "\u2610" // ☑ or ☐
                tasks.add("$symbol $title")
            }
        } catch (e: JSONException) {
            e.printStackTrace()
        }
    }

    override fun getViewAt(position: Int): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_list_item)
        views.setTextViewText(R.id.task_text, tasks[position])
        return views
    }

    override fun getCount(): Int = tasks.size
    override fun getLoadingView(): RemoteViews? = null
    override fun getViewTypeCount(): Int = 1
    override fun getItemId(position: Int): Long = position.toLong()
    override fun hasStableIds(): Boolean = true
    override fun onDestroy() {}
}
