package com.ethnoapp.bgita.model;

public class AppSettings {
	private boolean showSanskrit = true;
	private boolean showTranscription = true;
	private boolean showTranslate = true;
	private boolean showCommentary = true;
	private boolean audioTranslate;
	private boolean audioSanskrit;
	private boolean playAuto;

	public AppSettings() {
	}

	public AppSettings(boolean showSanskrit, boolean showTranscription, boolean showTranslate, boolean showCommentary, boolean audioSanskrit, boolean audioTranslate, boolean playAuto) {
		this.showSanskrit = showSanskrit;
		this.showTranscription = showTranscription;
		this.showTranslate = showTranslate;
		this.showCommentary = showCommentary;
		this.audioSanskrit = audioSanskrit;
		this.audioTranslate = audioTranslate;
		this.playAuto = playAuto;
	}

	public boolean isShowSanskrit() {
		return showSanskrit;
	}

	public void setShowSanskrit(boolean showSanskrit) {
		this.showSanskrit = showSanskrit;
	}

	public boolean isShowTranscription() {
		return showTranscription;
	}

	public void setShowTranscription(boolean showTranscription) {
		this.showTranscription = showTranscription;
	}

	public boolean isShowTranslate() {
		return showTranslate;
	}

	public void setShowTranslate(boolean showTranslate) {
		this.showTranslate = showTranslate;
	}

	public boolean isShowCommentary() {
		return showCommentary;
	}

	public void setShowCommentary(boolean showCommentary) {
		this.showCommentary = showCommentary;
	}

	public boolean isAudioTranslate() {
		return audioTranslate;
	}

	public void setAudioTranslate(boolean audioTranslate) {
		this.audioTranslate = audioTranslate;
	}

	public boolean isAudioSanskrit() {
		return audioSanskrit;
	}

	public void setAudioSanskrit(boolean audioSanskrit) {
		this.audioSanskrit = audioSanskrit;
	}

	public boolean isPlayAuto() {
		return playAuto;
	}

	public void setPlayAuto(boolean playAuto) {
		this.playAuto = playAuto;
	}
}
