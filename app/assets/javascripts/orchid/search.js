$(function() {
  // Filter collapse/expand indicators
  $('.search_form .panel-heading').click(function() {
    $this = $(this)
    if ( $this.find('.glyphicon-chevron-right').length > 0 ) {
      $this.find('.glyphicon-chevron-right')
        .toggleClass("glyphicon-chevron-down", true)
        .toggleClass("glyphicon-chevron-right", false);
    }
    else {
      $this.find('.glyphicon-chevron-down')
      .toggleClass("glyphicon-chevron-right", true)
      .toggleClass("glyphicon-chevron-down", false);
    }
  });
});

