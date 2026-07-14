package com.ironwaterstudio.server.listeners;

import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentActivity;
import android.support.v4.app.LoaderManager;
import android.support.v4.content.Loader;

import com.ironwaterstudio.server.Request;
import com.ironwaterstudio.server.ServiceLoader;
import com.ironwaterstudio.server.data.ApiResult;

import java.util.HashSet;

public class CallListener extends ProgressCallListener implements LoaderManager.LoaderCallbacks<ApiResult> {
	private String id;
	private Fragment fragment = null;

	public CallListener() {
		this(null);
	}

	public CallListener(boolean withProgress) {
		this(null, withProgress);
	}

	public CallListener(FragmentActivity activity) {
		this(activity, true);
	}

	public CallListener(FragmentActivity activity, boolean withProgress) {
		this(activity, withProgress, null);
	}

	public CallListener(FragmentActivity activity, Integer tag) {
		this(activity, true, tag);
	}

	public CallListener(FragmentActivity activity, boolean withProgress, Integer tag) {
		super(activity, withProgress);
		setTag(tag);
	}

	public void setTag(Integer tag) {
		this.id = String.valueOf(getClass().hashCode()) + (tag != null ? String.valueOf(tag) : "");
	}

	public String getId() {
		return id;
	}

	public LoaderManager getLoaderManager() {
		return fragment != null ? fragment.getLoaderManager() : getActivity().getSupportLoaderManager();
	}

	public void setFragment(Fragment fragment) {
		this.fragment = fragment;
	}

	@Override
	public final Loader<ApiResult> onCreateLoader(int i, Bundle bundle) {
		ServiceLoader loader = new ServiceLoader(getActivity());
		return addLoaderId(loader, i);
	}

	@Override
	public final void onLoadFinished(Loader<ApiResult> loader, final ApiResult result) {
		ServiceLoader serviceLoader = (ServiceLoader) loader;
		Request request = serviceLoader.getRequest();
		removeLoaderId(loader.getId());
		if (fragment != null && fragment.getActivity() == null) {
			onError(request, ApiResult.createCancel());
			return;
		}
		getLoaderManager().destroyLoader(loader.getId());
		if (result.isSuccess())
			onSuccess(request, result);
		else
			onError(request, result);
	}

	@Override
	public void onLoaderReset(Loader<ApiResult> loader) {
	}

	private ServiceLoader getLoader(int id) {
		Loader<ApiResult> loader = getLoaderManager().getLoader(id);
		return (ServiceLoader) loader;
	}

	public final void register(Fragment fragment) {
		setFragment(fragment);
		register(fragment.getActivity());
	}

	public final void register(FragmentActivity activity) {
		setActivity(activity);
		HashSet<Integer> loaderIds = getLoaderIds();
		HashSet<Integer> idsForRemove = new HashSet<>();
		for (Integer id : loaderIds) {
			Loader<ApiResult> loader = getLoader(id);
			if (loader != null && loader.isStarted()) {
				ServiceLoader serviceLoader = (ServiceLoader) loader;
				serviceLoader.setListener(this);
				getLoaderManager().initLoader(id, null, this);
			} else {
				idsForRemove.add(id);
			}
		}
		removeLoaderIds(idsForRemove);
	}

	public final void cancelLoad() {
		HashSet<Integer> loaderIds = getLoaderIds();
		for (Integer id : loaderIds) {
			Loader<ApiResult> baseLoader = getLoader(id);
			if (baseLoader != null && baseLoader.isStarted()) {
				ServiceLoader loader = (ServiceLoader) baseLoader;
				loader.cancelLoad(true);
			}
		}
	}

	private ServiceLoader addLoaderId(ServiceLoader loader, int id) {
		HashSet<Integer> loaderIds = getLoaderIds();
		loaderIds.add(id);
		getActivity().getIntent().putExtra(getId(), loaderIds);
		return loader;
	}

	@SuppressWarnings("unchecked")
	private HashSet<Integer> getLoaderIds() {
		HashSet<Integer> loaderIds = (HashSet<Integer>) getActivity().getIntent().getSerializableExtra(getId());
		if (loaderIds == null)
			loaderIds = new HashSet<>();
		return loaderIds;
	}

	private void removeLoaderId(Integer id) {
		HashSet<Integer> loaderIds = getLoaderIds();
		loaderIds.remove(id);
		getActivity().getIntent().putExtra(getId(), loaderIds);
	}

	private void removeLoaderIds(HashSet<Integer> ids) {
		if (ids == null || ids.isEmpty())
			return;
		HashSet<Integer> loaderIds = getLoaderIds();
		for (Integer id : ids)
			loaderIds.remove(id);
		getActivity().getIntent().putExtra(getId(), loaderIds);
	}
}
