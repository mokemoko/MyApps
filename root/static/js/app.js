$(function(){
  $("#modal_post").on('click', function(){
    $("#newpost").find("form").submit();
  });

  // 投稿削除ボタン押下時メソッド
  $("#post_del").on('click', function() {
    if(!confirm("本当に削除しますか？")) {
      return;
    }

    var id = $(this).attr("value");

    $.ajax({
      type: "POST",
      url: "/diary/delete",
      data: {
        id: id,
      },
      success: function() {
        $("#post_" + id).remove();
      },
      error: function() {
        alert("削除に失敗しました");
      },
    });
  });

  $(".controllable").hover(
      function() {
        $(".controllable").find('i').remove();
        var left = $(this).find('a').width() - 15;
        $(this).append('<i class="icon-heart fav_image" style="position: absolute; top: 0px; left: 0px;"></i>');
        $(this).append('<i class="icon-trash ignore_image" style="position: absolute; top: 0px; left: ' + left + 'px;"></i>');
      },
      function() {
      });

  $(".controllable").on("click", ".fav_image", function() {
    // お気に入りボタン押下
  });
  $(".controllable").on("click", ".ignore_image", function() {
    // 削除ボタン押下
    var elm = $(this).parent();
    var gid = elm.attr('id');
    $.ajax({
      type: "POST",
      url: "/image/ignore_image",
      data: {
        ".submit": 1,
        "gid": gid,
      },
      success: function() {
        elm.remove();
      },
      error: function() {
        alert("削除に失敗しました");
      },
    });
  });
});
