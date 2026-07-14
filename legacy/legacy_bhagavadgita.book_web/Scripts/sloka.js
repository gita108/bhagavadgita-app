$(function () {
	function addVocabulary() {
		$.ajax({
			url: '/admin/slokas/AddVocabulary',
			type: 'post',
			success: function (result) {
				$('.vocabularies .btn-add').before(result);
			},
			error: function () {
				window.location.reload();
			}
		});
	}

	function removeVocabulary() {
		$(this).parents('.row').remove();
	}

	$('.vocabularies').on('click', '.btn-remove', removeVocabulary);
	$('.vocabularies .btn-add').click(addVocabulary);
});