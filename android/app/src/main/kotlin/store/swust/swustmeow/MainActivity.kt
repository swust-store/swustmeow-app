package store.swust.swustmeow

import android.os.Bundle
import com.umeng.commonsdk.UMConfigure
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        UMConfigure.preInit(this, SecretsConfig.UMENG_APP_KEY, "Umeng")
    }
}
