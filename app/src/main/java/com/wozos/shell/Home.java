package com.wozos.shell;
import android.app.Activity;
import android.os.Bundle;
import android.content.Intent;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.graphics.Typeface;
import android.provider.Settings;
import android.view.*;
import android.widget.*;
import java.util.*;

public class Home extends Activity {
 private LinearLayout list; private String page="home"; private float x,y;
 private final int white=Color.WHITE, gray=0xff999999;
 @Override public void onCreate(Bundle b){super.onCreate(b); getWindow().setStatusBarColor(Color.BLACK);getWindow().setNavigationBarColor(Color.BLACK); show("home");}
 @Override protected void onNewIntent(Intent i){super.onNewIntent(i);show("home");}
 private int dp(float n){return (int)(n*Math.min(getResources().getDisplayMetrics().widthPixels/272f,getResources().getDisplayMetrics().heightPixels/480f)+.5f);}
 private TextView text(String s,int size,int color){TextView t=new TextView(this);t.setText(s);t.setTextSize(android.util.TypedValue.COMPLEX_UNIT_PX, size * Math.min(getResources().getDisplayMetrics().widthPixels / 272f, getResources().getDisplayMetrics().heightPixels / 480f));t.setTextColor(color);t.setTypeface(Typeface.create("sans-serif-light",Typeface.NORMAL));t.setIncludeFontPadding(false);return t;}
 private void row(String s,Runnable r){TextView t=text(s,30,white);t.setPadding(0,dp(4),0,dp(4));t.setMinHeight(dp(40));t.setFocusable(true);t.setOnClickListener(v->r.run());list.addView(t);}
 private void label(String s){TextView t=text(s,13,gray);t.setPadding(0,dp(16),0,dp(8));list.addView(t);}
 private void app(String name,String pkg){row(name,()->{Intent i=getPackageManager().getLaunchIntentForPackage(pkg);if(i!=null){try{startActivity(i);}catch(Exception e){notice();}}else notice();});}
 private void notice(){Toast.makeText(this,"Application unavailable",Toast.LENGTH_SHORT).show();}
 private void settings(String action){try{startActivity(new Intent(action));}catch(Exception e){notice();}}
 private void show(String p){page=p; LinearLayout root=new LinearLayout(this);root.setOrientation(1);root.setBackgroundColor(Color.BLACK);root.setPadding(dp(14),dp(8),dp(8),0);
 LinearLayout nav=new LinearLayout(this);for(String s:new String[]{"menu","quickplay"}){TextView t=text(s,15,s.equals(p)||s.equals("menu")&&p.equals("home")?white:gray);t.setPadding(0,dp(8),dp(26),dp(12));t.setOnClickListener(v->show(s.equals("menu")?"home":s));nav.addView(t);}root.addView(nav);
 if(!p.equals("home")){TextView title=text(p,48,white);title.setSingleLine(true);root.addView(title);}
 ScrollView scroll=new ScrollView(this);scroll.setFillViewport(true);scroll.setVerticalScrollBarEnabled(false);list=new LinearLayout(this);list.setOrientation(1);list.setPadding(0,dp(12),0,dp(24));scroll.addView(list);root.addView(scroll,new LinearLayout.LayoutParams(-1,0,1));setContentView(root);
 switch(p){case "home": for(String s:new String[]{"music","videos","pictures","internet","library","apps","settings"})row(s,()->show(s));break;
 case "quickplay":label("pinned");app("spotify","com.spotify.music");app("brave","com.brave.browser");app("libby","com.overdrive.mobile.android.libby");label("video");app("max","com.wbd.stream");app("hulu","com.hulu.plus");break;
 case "music":app("spotify","com.spotify.music");app("local music","org.lineageos.twelve");break;
 case "videos":app("max","com.wbd.stream");app("hulu","com.hulu.plus");app("files","com.android.documentsui");break;
 case "pictures":app("gallery","org.lineageos.glimpse");break;
 case "internet":app("brave","com.brave.browser");break;
 case "library":app("libby","com.overdrive.mobile.android.libby");app("files","com.android.documentsui");break;
 case "settings":row("wireless",()->settings(Settings.ACTION_WIFI_SETTINGS));row("display",()->settings(Settings.ACTION_DISPLAY_SETTINGS));row("sound",()->settings(Settings.ACTION_SOUND_SETTINGS));row("system",()->settings(Settings.ACTION_SETTINGS));row("about",()->settings(Settings.ACTION_DEVICE_INFO_SETTINGS));row("home app",()->settings(Settings.ACTION_HOME_SETTINGS));break;
 case "apps":Intent q=new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER);List<ResolveInfo> a=getPackageManager().queryIntentActivities(q,0);a.sort(Comparator.comparing(r->r.loadLabel(getPackageManager()).toString(),String.CASE_INSENSITIVE_ORDER));for(ResolveInfo r:a){if(r.activityInfo.packageName.equals(getPackageName()))continue;row(r.loadLabel(getPackageManager()).toString(),()->{try{startActivity(new Intent(Intent.ACTION_MAIN).addCategory(Intent.CATEGORY_LAUNCHER).setClassName(r.activityInfo.packageName,r.activityInfo.name));}catch(Exception e){notice();}});}break;}
 root.setAlpha(.65f);root.animate().alpha(1).setDuration(150).start();}
 @Override public boolean dispatchTouchEvent(android.view.MotionEvent e){if(e.getAction()==0){x=e.getX();y=e.getY();}if(e.getAction()==1&&Math.abs(e.getX()-x)>dp(100)&&Math.abs(e.getY()-y)<dp(65)){MotionEvent cancel=MotionEvent.obtain(e);cancel.setAction(MotionEvent.ACTION_CANCEL);super.dispatchTouchEvent(cancel);cancel.recycle();show(page.equals("home")&&e.getX()<x?"quickplay":"home");return true;}return super.dispatchTouchEvent(e);}
 @Override public void onBackPressed(){show("home");}
}
