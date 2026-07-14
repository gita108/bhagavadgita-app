$(function () {
	function loadChapters() {
		var bookId = $(this).val();
		$.ajax({
			url: '/admin/slokas/chapters',
			type: 'post',
			data: { bookId: bookId },
			success: function (result) {
				$('select[name*="ChapterId"]').parent().html(result);
			},
			error: function () {
				window.location.reload();
			}
		});
	}

	$('select[name*="BookId"]').change(loadChapters);
});