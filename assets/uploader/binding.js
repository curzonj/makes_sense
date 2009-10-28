(function($) {
  $(document).ready(function() {
    $(".uploader").each(function() {
      $(this).data("swfupload", new SWFUpload({
        flash_url                     : "/javascripts/uploader/swfupload.swf",
        upload_url                    : uploadPolicy.action,
        post_params                   : uploadPolicy.params,
        upload_limit                  : 1,
        http_success                  : [201],
        file_post_name                : 'file',
        file_size_limit               : "200 MB",
        file_types                    : "*.pdf",
        file_types_description        : "PDF Documents",
        button_placeholder            : this,
        button_width                  : 380,
        button_height                 : 32,
        button_text                   : 'Upload PDF Document',
        button_action                 : SWFUpload.BUTTON_ACTION.SELECT_FILE,
        button_window_mode            : SWFUpload.WINDOW_MODE.WINDOW,
        button_cursor                 : SWFUpload.CURSOR.HAND,
        file_queue_error_handler      : fileQueueError,
        file_dialog_complete_handler  : fileDialogComplete,
        upload_progress_handler       : uploadProgress,
        upload_error_handler          : uploadError,
        upload_success_handler        : uploadSuccess,
        upload_complete_handler       : uploadComplete,
        custom_settings               : {
          upload_target: "divFileProgressContainer"
        }
      }))
    })
  })
})(jQuery);
