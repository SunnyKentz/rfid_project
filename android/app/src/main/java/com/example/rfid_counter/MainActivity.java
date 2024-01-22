package com.example.rfid_counter;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Random;

import com.cipherlab.rfid.*;
import com.cipherlab.rfidapi.RfidManager;
import com.cipherlab.rfidapi.RfidManagerAPI;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;

import android.os.Handler;
import android.os.Looper;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;
import android.os.Environment;
import android.util.Log;

public class MainActivity extends FlutterActivity {
    
    RfidManager mRfidManager = null;
	String TAG = "RFID_sample";

    final private String CHANNEL = "com.example.rfid_counter/method";
	final private String ECHANNEL = "com.example.rfid_counter/event";
    private MethodChannel channel;
	private  EventChannel eChannel;
	private EventChannel.EventSink eventSink;
	private HashMap<String,Object> answer;
	private Handler handler;
    
	@Override
    public void configureFlutterEngine(FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        
		handler = new Handler(Looper.getMainLooper());
        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
		BinaryMessenger eMessenger = flutterEngine.getDartExecutor().getBinaryMessenger();
		
		eChannel = new EventChannel(eMessenger,ECHANNEL);
        channel = new MethodChannel(messenger, CHANNEL);
		
        channel.setMethodCallHandler((call,result) -> {

			switch (call.method) {
				case "init":
					init();
					break;
				case "start":
					start();
					result.success(true);
					break;
				case "stop":
					stop();
					break;
				case "setDistance":
					final int dist = call.argument("dist");
					setDistance(dist);
					break;
				default:
					result.notImplemented();
					break;
			}
        });
    }

    void init(){
        /*RfidManagerAPI mRfidManagerAPI = RfidManagerAPI.GetInstance(this.getActivity());
		mRfidManager = RfidManager.InitInstance(this.getActivity());

        IntentFilter filter = new IntentFilter();
		filter.addAction(GeneralString.Intent_RFIDSERVICE_CONNECTED);
		filter.addAction(GeneralString.Intent_RFIDSERVICE_TAG_DATA);
		filter.addAction(GeneralString.Intent_RFIDSERVICE_EVENT);
		filter.addAction(GeneralString.Intent_FWUpdate_ErrorMessage);
		filter.addAction(GeneralString.Intent_FWUpdate_Percent);
		filter.addAction(GeneralString.Intent_FWUpdate_Finish);
		filter.addAction(GeneralString.Intent_GUN_Attached);
		filter.addAction(GeneralString.Intent_GUN_Unattached);
		filter.addAction(GeneralString.Intent_GUN_Power);
		this.getActivity().registerReceiver(myDataReceiver, filter);*/

		/*Runnable newThread = new Runnable() {
			@Override
			public void run() {
				try{Thread.sleep(5000);}catch(Exception e){Log.e(TAG,e.toString());}
				for(int i = 0; i<10;i++){
					HashMap<String,Object> answer = new HashMap<>();
					answer.put("EPC", "A");
					answer.put("EPC", "B");
					answer.put("EPC", "C");
					channel.invokeMethod("addReadData", answer);
					Log.d(TAG,(String)answer.get("EPC"));
					try{Thread.sleep(500);}catch(Exception e){Log.e(TAG,e.toString());}
				}
				try {
					Thread.currentThread().join();
				} catch (Exception e) {
					Log.e(TAG,"Could not yeild thread" + e.toString());
				}
			}
		};
		(new Thread(newThread)).start();*/
		
	}

    /*void setScanMode(int mode){
		//arg mode : 0 = continious, 1 = single
		 
		ScanMode scanMode =  mRfidManager.setScanMode((mode==1)?ScanMode.Single:ScanMode.Continuous);
		if(scanMode == ScanMode.Err){
			String m = mRfidManager.GetLastError();
			Log.e(TAG, "GetLastError = " + m);
		}else{
			Log.i(TAG, "GetScanMode = " + scanMode );
		}

    }*/

	void setDistance(int dist){
		Log.i(TAG,"distance :"+dist);
    }

	void start(){
		eChannel.setStreamHandler(streamHandler);
	}
	void stop(){
		eventSink.endOfStream(); // ends the stream
	}

	private Runnable r = new Runnable() {
		@Override
		public void run() {
			String[] cat = {"Pillow Case","Bedsheet","Towel","None","Puppy"};
			for(int i = 0; i<10;i++){
				answer = new HashMap<>();
				answer.put("EPC", "0058041c1602019008e7d387");
				answer.put("Data", "4adf30000058041c1602019008e7d387");
				answer.put("Category", cat[(new Random()).nextInt(5)]);
				eventSink.success(answer);
				
			}
		}
	};

	private final EventChannel.StreamHandler streamHandler = new EventChannel.StreamHandler(){
		@Override
		public void onListen(Object data, EventChannel.EventSink events){
			eventSink = events;
			r.run();
		}
		@Override
		public void onCancel(Object arguments){
			eventSink = null;
		}
	};
    /*private final BroadcastReceiver myDataReceiver = new BroadcastReceiver(){
		@Override
		public void onReceive(Context context, Intent intent) {
			if(intent.getAction().equals(GeneralString.Intent_RFIDSERVICE_CONNECTED)){
				String PackageName = intent.getStringExtra("PackageName");
				
				// / make sure this AP does already connect with RFID service (after call RfidManager.InitInstance(this)
				if(mRfidManager.GetConnectionStatus()){
					int mStatus = mRfidManager.GetRFIDSwitchStatus();
					if (mStatus!=-1) {
						Log.i(TAG, "GetRFIDSwitchStatus = " + mStatus);	
					}else{
						String m = mRfidManager.GetLastError();
						Log.e(TAG, "GetLastError = " + m);
					}
					ScanMode mode =  mRfidManager.GetScanMode();
					if(mode == ScanMode.Err){
						String m = mRfidManager.GetLastError();
		                Log.e(TAG, "GetLastError = " + m);
					}else{
						Log.i(TAG, "GetScanMode = " + mode );
					}
					
				}
			}else if(intent.getAction().equals(GeneralString.Intent_RFIDSERVICE_TAG_DATA)){
				handler.post(executeSaveData);
			}
        }
    };

	private Runnable executeSaveData = new Runnable(){
		@Override
		public void run() {
			//type : 0=Normal scan (Press Trigger Key to receive the data) ; 1=Inventory EPC ; 2=Inventory ECP TID ; 3=Reader tag ; 5=Write tag ; 6=Lock tag ; 7=Kill tag ; 8=Authenticate tag ; 9=Untraceable tag
				//response : 0=RESPONSE_OPERATION_SUCCESS ; 1=RESPONSE_OPERATION_FINISH ; 2=RESPONSE_OPERATION_TIMEOUT_FAIL ; 6=RESPONSE_PASSWORD_FAIL ; 7=RESPONSE_OPERATION_FAIL ;251=DEVICE_BUSY
				
				int type = intent.getIntExtra(GeneralString.EXTRA_DATA_TYPE, -1);
				int response = intent.getIntExtra(GeneralString.EXTRA_RESPONSE, -1);
				double data_rssi = intent.getDoubleExtra(GeneralString.EXTRA_DATA_RSSI, 0);
				
				String PC = intent.getStringExtra(GeneralString.EXTRA_PC);
				String EPC = intent.getStringExtra(GeneralString.EXTRA_EPC);
				String TID = intent.getStringExtra(GeneralString.EXTRA_TID);
				String ReadData = intent.getStringExtra(GeneralString.EXTRA_ReadData);
				int EPC_length = intent.getIntExtra(GeneralString.EXTRA_EPC_LENGTH, 0);
				int TID_length = intent.getIntExtra(GeneralString.EXTRA_TID_LENGTH, 0);
				int ReadData_length = intent.getIntExtra(GeneralString.EXTRA_ReadData_LENGTH, 0);
				
				Log.w(TAG, "++++ [Intent_RFIDSERVICE_TAG_DATA] ++++");
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] type=" + type + ", response=" + response + ", data_rssi="+data_rssi   );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] PC=" + PC );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] EPC=" + EPC );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] EPC_length=" + EPC_length );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] TID=" + TID );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] TID_length=" + TID_length );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] ReadData=" + ReadData );
				Log.d(TAG, "[Intent_RFIDSERVICE_TAG_DATA] ReadData_length=" + ReadData_length );
				
				// If type=8 ; Authenticate response data in ReadData
				if(type==GeneralString.TYPE_AUTHENTICATE_TAG && response==GeneralString.RESPONSE_OPERATION_SUCCESS){
					Log.i(TAG, "Authenticate response data=" + ReadData );
				}

				answer = new HashMap<>();
				answer.put("type", type);
				answer.put("response", response);
				answer.put("data_rssi", data_rssi);
				answer.put("data_rssi", data_rssi);
				answer.put("PC", PC);
				answer.put("EPC", EPC);
				answer.put("TID", TID);
				answer.put("ReadData", ReadData);
				answer.put("EPC_length", EPC_length);
				answer.put("TID_length", TID_length);
				answer.put("ReadData_length", ReadData_length);
				eventSink.success(answer);
		}
	};*/
}
