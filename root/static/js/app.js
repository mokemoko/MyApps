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

  // 追加画面で投稿数を表示する
});
