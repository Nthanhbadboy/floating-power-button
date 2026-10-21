package com.floatingbutton.app

import android.content.Context
import android.view.View
import com.huawei.hms.ads.AdListener
import com.huawei.hms.ads.AdParam
import com.huawei.hms.ads.HwAds
import com.huawei.hms.ads.BannerAdSize
import com.huawei.hms.ads.banner.BannerView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

/**
 * Native Huawei Petal Ads banner (320x50), embedded by Flutter as the
 * platform view `power_volume/petal_banner`.
 *
 * Load results are reported to Dart on `power_volume/petal_ads_events`;
 * Dart falls back to Google AdMob when this banner fails or times out
 * (see AdBannerHost).
 */
class PetalBannerView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    messenger: BinaryMessenger,
) : PlatformView {

    private val events = MethodChannel(messenger, EVENT_CHANNEL)
    private val bannerView = BannerView(context)

    init {
        try {
            HwAds.init(context)
        } catch (e: Exception) {
            events.invokeMethod("onPetalBannerFailed", mapOf("viewId" to id, "error" to "init: ${e.message}"))
        }
        bannerView.adId = creationParams?.get("adUnitId") as? String
            ?: DEFAULT_AD_UNIT_ID
        bannerView.setBannerAdSize(BannerAdSize.BANNER_SIZE_320_50)
        bannerView.setAdListener(object : AdListener() {
            override fun onAdLoaded() {
                events.invokeMethod("onPetalBannerLoaded", mapOf("viewId" to id))
            }

            override fun onAdFailed(errorCode: Int) {
                events.invokeMethod(
                    "onPetalBannerFailed",
                    mapOf("viewId" to id, "error" to errorCode.toString()),
                )
            }
        })
        bannerView.loadAd(AdParam.Builder().build())
    }

    override fun getView(): View = bannerView

    override fun dispose() {
        bannerView.destroy()
    }

    companion object {
        const val EVENT_CHANNEL = "power_volume/petal_ads_events"

        /** Huawei public TEST banner slot — replaced from Dart creation
         *  params (AppInfo.petalBannerAdUnitId) in production. */
        const val DEFAULT_AD_UNIT_ID = "testw6vs28auh3"
    }
}
