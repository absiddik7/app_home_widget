package com.example.home_widget_practice

import android.content.Intent
import android.widget.RemoteViewsService

class AllTodoWidgetService : RemoteViewsService() {
    override fun onGetViewFactory(intent: Intent): RemoteViewsFactory {
        return AllTodoWidgetFactory(this.applicationContext)
    }
}
