package com.example.rfid_counter;

import java.util.ArrayList;

import com.cipherlab.rfid.*;
import com.cipherlab.rfidapi.RfidManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.BinaryMessenger;

public class MainActivity extends FlutterActivity {
    
    RfidManager mRfidManager = null;
	String TAG = "RFID_sample";

    final private String CHANNEL = "com.example.rfid_counter/read";
    private MethodChannel channel;

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine){
        super.configureFlutterEngine(flutterEngine);
        
        ArrayList<String> errors = new ArrayList<String>(init());
        BinaryMessenger messenger = flutterEngine.getDartExecutor().getBinaryMessenger();
        channel = new MethodChannel(messenger, CHANNEL);
        channel.setMethodCallHandler((call,result) -> {

            if (call.method.equals("read")){
                errors.add(read());
                result.success(errors);
            }else{
                result.notImplemented();
            }
        });
    }

    ArrayList<String> init(){
        ArrayList<String> err = new ArrayList<String>();
        mRfidManager = RfidManager.InitInstance(this);
        
        try {
			int re = mRfidManager.ResetToDefault();
			if (re != ClResult.S_OK.ordinal()) {
				String m = mRfidManager.GetLastError();
				err.add("Reset:" + m);
			}
		} catch (Exception e) {
			err.add("Reset" + e.toString());
		}

        int re = mRfidManager.EnableDeviceTrigger(true);
		if (re != ClResult.S_OK.ordinal()) {
			String m = mRfidManager.GetLastError();
			err.add("enable trigger:" + m);
		}
        
        mRfidManager.KeepDeviceAlive();
        
        re =mRfidManager.SetRFIDMode(RFIDMode.ReadTag);
        if(re!=ClResult.S_OK.ordinal())
        {
            String m = mRfidManager.GetLastError();
            err.add("Set RFIDMODE:" + m);
        }

        return err;
    }

    String read(){
        int re = mRfidManager.RFIDReadTagMassive(null, RFIDMemoryBank.EPC, 0,0);
        String err;
        if(re!=ClResult.S_OK.ordinal())
        {
            err ="EPC : " + mRfidManager.GetLastError();
        }else{
            err = "Could not read";
        }
        return err;
    }
}
