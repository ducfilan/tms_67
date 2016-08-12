$ ->
  $("div[class*=course_action_] a").click (e) ->
    self = $(this)

    if confirm($(this).data("confirm"))
      $.ajax
        url: $(this).attr("href")
        type: "PATCH"
        dataType: "json"
        error: (jqXHR, textStatus, errorThrown) ->
          alert "AJAX Error: #{textStatus}"
        success: (data, textStatus, jqXHR) ->
          debugger
          self.parent().html(data.htmlText)

    e.preventDefault()
    e.stopPropagation()
