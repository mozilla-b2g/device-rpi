
// rpi devices have an eth0 interface through an rndis.  But
// gecko/gonk don't know to configure that yet.  So instead, we
// attempt to configure it "manually" and tell gecko not to manage
// offline status, since if we successfully bring up eth0, gecko won't
// know.
user_pref("network.gonk.manage-offline-status", false);

// Force-disable accelerated graphics while the GL stack isn't fully
// functional.
user_pref("layers.acceleration.force-enabled", false);
user_pref("layers.acceleration.disabled", true);
user_pref("layers.offmainthreadcomposition.force-basic", true);
user_pref("layers.gralloc.disable", true);

//user_pref("gfx.draw-color-bars", true);
//user_pref("layers.acceleration.draw-fps", true);
//user_pref("layers.frame-counter", true);
//user_pref("layers.bench.enabled", true);
//user_pref("gfx.layerscope.enabled", true);
user_pref("app.reportCrashes", false);
