package com.ethnoapp.bgita.screens;

import android.content.Intent;
import android.os.Bundle;
import android.support.v4.view.ViewPager;
import android.support.v7.app.AppCompatActivity;
import android.view.View;
import android.widget.Button;

import com.ethnoapp.bgita.R;
import com.ethnoapp.bgita.adapters.GuidePagerAdapter;
import com.ethnoapp.bgita.model.AppState;
import com.ethnoapp.bgita.model.Guide;
import com.ethnoapp.bgita.model.Settings;
import com.ironwaterstudio.utils.GaUtils;
import com.viewpagerindicator.IconPageIndicator;

import java.util.ArrayList;
import java.util.Arrays;


public class GuideActivity extends AppCompatActivity {
	private ViewPager vpGuide;
	private IconPageIndicator piGuide;
	private Button btnNext;
	private Button btnBack;
	private Button btnSkip;
	private GuidePagerAdapter adapter = null;

	private ViewPager.OnPageChangeListener pageChangeListener = new ViewPager.OnPageChangeListener() {
		@Override
		public void onPageScrolled(int position, float positionOffset, int positionOffsetPixels) {
		}

		@Override
		public void onPageSelected(int position) {
			btnBack.setVisibility(position == 0 ? View.INVISIBLE : View.VISIBLE);
			btnNext.setVisibility(position == Guide.values().length - 1 ? View.INVISIBLE : View.VISIBLE);
		}

		@Override
		public void onPageScrollStateChanged(int state) {
		}
	};

	private View.OnClickListener skipClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			skip();
			GaUtils.logEvent(UiConstants.GA_CATEGORY_GUIDE, "Click Skip guide");
		}
	};

	private View.OnClickListener nextClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			if (vpGuide.getCurrentItem() != adapter.getCount() - 1) {
				vpGuide.setCurrentItem(vpGuide.getCurrentItem() + 1);
				GaUtils.logEvent(UiConstants.GA_CATEGORY_GUIDE, "Click Next guide: index " + (vpGuide.getCurrentItem() + 1));
			} else {
				skip();
			}
		}
	};

	private View.OnClickListener backClickListener = new View.OnClickListener() {
		@Override
		public void onClick(View v) {
			if (vpGuide.getCurrentItem() > 0)
				vpGuide.setCurrentItem(vpGuide.getCurrentItem() - 1);
			GaUtils.logEvent(UiConstants.GA_CATEGORY_GUIDE, "Click Back guide: index " + (vpGuide.getCurrentItem() - 1));
		}
	};

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_guide);

		vpGuide = findViewById(R.id.vp_guide);
		piGuide = findViewById(R.id.pi_guide);
		btnNext = findViewById(R.id.btn_next);
		btnBack = findViewById(R.id.btn_back);
		btnSkip = findViewById(R.id.btn_skip);

		btnNext.setOnClickListener(nextClickListener);
		btnBack.setOnClickListener(backClickListener);
		btnSkip.setOnClickListener(skipClickListener);

		adapter = new GuidePagerAdapter(this, new ArrayList<>(Arrays.asList(Guide.values())));
		vpGuide.setAdapter(adapter);
		vpGuide.addOnPageChangeListener(pageChangeListener);
		piGuide.setViewPager(vpGuide);
	}

	@Override
	public void onBackPressed() {

	}

	private void skip() {
		Settings.getInstance().setAppState(AppState.MAIN);
		Settings.getInstance().save();
		Intent intent = new Intent(this, MainActivity.class);
		intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TASK | Intent.FLAG_ACTIVITY_NEW_TASK);
		startActivity(intent);
	}
}
