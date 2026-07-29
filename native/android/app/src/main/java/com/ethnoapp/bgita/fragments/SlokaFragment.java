package com.ethnoapp.bgita.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.support.annotation.Nullable;
import android.support.v4.app.Fragment;
import android.support.v7.widget.RecyclerView;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.CommentariesAdapter;
import com.ethnoapp.bgita.adapters.TranslationsAdapter;
import com.ethnoapp.bgita.model.Commentary;
import com.ethnoapp.bgita.model.Settings;
import com.ethnoapp.bgita.model.Sloka;
import com.ethnoapp.bgita.model.SlokaInfo;
import com.ethnoapp.bgita.model.Translation;
import com.ethnoapp.bgita.model.Vocabulary;
import com.ethnoapp.bgita.screens.UiConstants;
import com.ironwaterstudio.utils.GaUtils;

import java.util.ArrayList;
import java.util.Collections;

public class SlokaFragment extends Fragment {
	private TextView tvName;
	private TextView tvChapter;
	private TextView tvSanskrit;
	private TextView tvTranscription;
	private TextView tvTranslation;
	private ImageView ivSanskritDivider;
	private ImageView ivTranslationDivider;
	private ImageView ivCommentaryDivider;
	private ImageView ivPrev;
	private ImageView ivNext;
	private RecyclerView rvTranslations;
	private RecyclerView rvCommentary;
	private Button btnMore;

	private String audioTitle;
	private Sloka sloka;
	private ArrayList<Translation> translations = new ArrayList<>();
	private ArrayList<Commentary> commentaries = new ArrayList<>();
	private TranslationsAdapter translationsAdapter;
	private CommentariesAdapter commentariesAdapter;

	private View.OnClickListener moreClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			if (commentariesAdapter.getItemCount() == 1) {
				btnMore.setText(R.string.minimize);
				commentariesAdapter.animateTo(commentaries);
			} else {
				btnMore.setText(getActivity().getResources().getQuantityString(R.plurals.interpretations, commentaries.size() - 1, commentaries.size() - 1));
				commentariesAdapter.animateTo(new ArrayList<>(Collections.singletonList(commentaries.get(0))));
			}
			GaUtils.logEvent(UiConstants.GA_CATEGORY_UI, "Click more commentaries");
		}
	};

	private View.OnClickListener moveClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			getContext().sendBroadcast(new Intent(UiConstants.ACTION_SLOKA_MOVE).putExtra(UiConstants.KEY_DIR, v.getId() == R.id.iv_next ? 1 : -1));
			GaUtils.logEvent(UiConstants.GA_CATEGORY_SHOW_SLOKA, "Click Next or Back sloka");
		}
	};

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		View v = inflater.inflate(R.layout.fragment_sloka, container, false);
		tvName = v.findViewById(R.id.tv_name);
		ivNext = v.findViewById(R.id.iv_next);
		ivPrev = v.findViewById(R.id.iv_prev);
		tvChapter = v.findViewById(R.id.tv_chapter);
		ivSanskritDivider = v.findViewById(R.id.iv_sanskrit_divider);
		tvSanskrit = v.findViewById(R.id.tv_sanskrit);
		tvTranscription = v.findViewById(R.id.tv_transcription);
		ivTranslationDivider = v.findViewById(R.id.iv_translation_divider);
		tvTranslation = v.findViewById(R.id.tv_translation);
		rvTranslations = v.findViewById(R.id.rv_translations);
		ivCommentaryDivider = v.findViewById(R.id.iv_commentary_divider);
		rvCommentary = v.findViewById(R.id.rv_commentary);
		btnMore = v.findViewById(R.id.btn_more);

		return v;
	}

	@Override
	public void onActivityCreated(@Nullable Bundle savedInstanceState) {
		super.onActivityCreated(savedInstanceState);
		sloka = (Sloka) getArguments().getSerializable(UiConstants.KEY_SEND_SLOKA);
		if (sloka == null)
			return;

		ivNext.setOnClickListener(moveClickListener);
		ivPrev.setOnClickListener(moveClickListener);
		rvTranslations.setNestedScrollingEnabled(false);
		rvCommentary.setNestedScrollingEnabled(false);
		btnMore.setOnClickListener(moreClickListener);

		setData();
	}

	private void setData() {
		ArrayList<SlokaInfo> slokaInfos = SlokaInfo.getList(sloka.getChapterId(), sloka.getOrder());
		SlokaInfo slokaInfo = SlokaInfo.find(slokaInfos, sloka.getId());
		if (slokaInfo == null)
			return;

		translations = SlokaInfo.getTranslations(slokaInfos);
		commentaries = SlokaInfo.getCommentaries(slokaInfos);

		tvName.setText(sloka.getName());
		tvChapter.setText(slokaInfo.getChapterName());
		audioTitle = String.format("%s %s", sloka.getName(), slokaInfo.getChapterName());
		ivPrev.setVisibility(isFirst() ? View.GONE : View.VISIBLE);
		ivNext.setVisibility(isLast() ? View.GONE : View.VISIBLE);
		if (Settings.getInstance().getAppSettings().isShowSanskrit()) {
			ivSanskritDivider.setVisibility(View.VISIBLE);
			tvSanskrit.setText(sloka.getText());
		} else {
			ivSanskritDivider.setVisibility(View.GONE);
			tvSanskrit.setVisibility(View.GONE);
		}
		if (Settings.getInstance().getAppSettings().isShowTranscription()) {
			if (ivSanskritDivider.getVisibility() == View.GONE)
				ivSanskritDivider.setVisibility(View.VISIBLE);
			tvTranscription.setText(sloka.getTranscription());
		} else
			tvTranscription.setVisibility(View.GONE);
		if (Settings.getInstance().getAppSettings().isShowTranslate()) {
			ivTranslationDivider.setVisibility(View.VISIBLE);
			tvTranslation.setText(Vocabulary.buildDictionary(getContext(), Vocabulary.getList(sloka.getId())));
		} else {
			ivTranslationDivider.setVisibility(View.GONE);
			tvTranslation.setVisibility(View.GONE);
		}
		translationsAdapter = new TranslationsAdapter(getContext(), translations);
		rvTranslations.setAdapter(translationsAdapter);

		if (Settings.getInstance().getAppSettings().isShowCommentary() && commentaries.size() > 0) {
			ivCommentaryDivider.setVisibility(View.VISIBLE);
			commentariesAdapter = new CommentariesAdapter(getContext(), new ArrayList<>(Collections.singletonList(commentaries.get(0))));
			rvCommentary.setAdapter(commentariesAdapter);
			if (commentaries.size() > 1) {
				btnMore.setVisibility(View.VISIBLE);
				btnMore.setText(this.getResources().getQuantityString(R.plurals.interpretations, commentaries.size() - 1, commentaries.size() - 1));
			} else {
				btnMore.setVisibility(View.GONE);
			}
		} else {
			ivCommentaryDivider.setVisibility(View.GONE);
			rvCommentary.setVisibility(View.GONE);
			btnMore.setVisibility(View.GONE);
		}
	}

	private boolean isFirst() {
		return getArguments() != null && getArguments().getBoolean(UiConstants.KEY_IS_FIRST);
	}

	private boolean isLast() {
		return getArguments() != null && getArguments().getBoolean(UiConstants.KEY_IS_LAST);
	}

	public String getAudioTitle() {
		return audioTitle;
	}

	public int getPosition() {
		return getArguments().getInt(UiConstants.KEY_POS, -1);
	}

	public static SlokaFragment newInstance(Sloka sloka, boolean isFirst, boolean isLast, int position) {
		Bundle args = new Bundle();
		args.putSerializable(UiConstants.KEY_SEND_SLOKA, sloka);
		args.putSerializable(UiConstants.KEY_IS_FIRST, isFirst);
		args.putSerializable(UiConstants.KEY_IS_LAST, isLast);
		args.putInt(UiConstants.KEY_POS, position);
		SlokaFragment fragment = new SlokaFragment();
		fragment.setArguments(args);
		return fragment;
	}
}
